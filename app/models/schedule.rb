class Schedule < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  attr_accessible :user_id, :message, :gdata_content, :week_start, :week_end, :status, :cc, :from, :ending_content, :daily_schedule

  serialize :daily_schedule

  belongs_to :user, :touch => true

  scope :by_type, lambda {|type| self.find_schedules_by_type(type)}

  def self.delete_obsolete
    where("week_start < ?", Time.zone.end_of_previous_week).delete_all
  end

  def self.reload_schedules
    self.delete_obsolete
    User.all.each(&:update_schedules)
  end

  def can_send_out?
    return !!self.user && !!self.user.group && self.user.group.display && !self.user.in_no_team?
  end

  def send_out
    raise  "Can not send out schedule" unless self.can_send_out?
    Mailer.schedule_summary(self).deliver
  end

  def self.find_schedules_by_type(type='this_week')
    if type == 'this_week'
      schedules = Schedule.where("week_start > ?", Time.zone.end_of_previous_week)
    elsif type == 'last_week'
      schedules = Schedule.where("week_start = ?", Time.zone.end_of_previous_week)
    end
  end

  def self.send_schedules_out(type='this_week')
    schedules = self.find_schedules_by_type type
    schedules.each do |schedule|
      begin
        schedule.send_out
        puts "@@@@@@@@@@@@ --- sent to #{schedule.user.name}"
      rescue
        message = "Something wrong with mailer... please resend."
        next
      end
    end
    AppSettings.done_sending_weekly_mails == 'yes'
    AppSettings.done_sending_weekly_mails_time = "#{Time.zone.now.to_date.to_s(:db)}"
  end

  def cc_emails
    return "" if cc.blank?
    cc.split(",")
  end

  def calculate_daily_schedule
    return unless week_hours.present?

    self.daily_schedule = DailySchedule.new []
    project_hours = get_project_hours

    DailySchedule::SHORT_DAY_NAMES.each do |day|
      daily_schedule.add extract_single_day_schedule(project_hours)
    end
  end

  private

  def week_hours
    user.week_hours.where(week: week_start).includes(:raw_item)
  end
  memoize :week_hours

  def get_project_hours
    week_hours
      .map {|wh| {project: wh.raw_item.linked_project, hours: wh.hours.to_f} }
      .sort_by {|ph| [-ph[:hours], ph[:project].date_target.to_s]}
  end

  def daily_hours_average
    hours_avg = week_hours.map {|wh| wh.hours.to_f }.sum / DailySchedule::SHORT_DAY_NAMES.size
    hours_avg = 8.0 if hours_avg < 8.0
    hours_avg
  end
  memoize :daily_hours_average

  def extract_single_day_schedule(project_hours)
    schedule = []
    quota = daily_hours_average

    while ph = project_hours.shift
      if ph[:hours] >= quota
        schedule << { pname: ph[:project].name, pid: ph[:project].id, hours: quota.round(3) }
        ph[:hours] = ph[:hours] - quota
        project_hours.unshift(ph) if ph[:hours] > 0
        break
      else
        schedule << { pname: ph[:project].name, pid: ph[:project].id, hours: ph[:hours].round(3) }
        quota = quota - ph[:hours]
        break if quota < 0.001
      end
    end

    schedule
  end

end
