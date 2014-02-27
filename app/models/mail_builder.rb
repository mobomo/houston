class MailBuilder
  extend ActiveSupport::Memoizable

  attr :schedule

  def initialize(schedule)
    @schedule = schedule
    @summary = {}
  end

  def group
    schedule.user.group
  end

  def to
    "#{schedule.user.name} <#{schedule.user.email}>"
  end

  def from
    schedule.from.blank? ? group.from : schedule.from
  end

  def cc
    schedule.cc_emails.blank? ? group.cc : schedule.cc_emails
  end

  def greeting_name
    schedule.user.first_name
  end

  def week_beginning
    (schedule.week_start + 1.day).to_date.to_s(:short)
  end

  def hours_headers
    WEEK_RANGE.map {|i| (schedule.week_start.monday + i.weeks).to_date.strftime("%m/%d") }
  end

  def message_in_html
    @message_in_html ||= MarkdownRenderer.render(schedule.message.blank? ? group.message : schedule.message)
  end

  def ending_content_in_html
    @ending_content_in_html ||= MarkdownRenderer.render(schedule.ending_content.blank? ? group.ending_content : schedule.ending_content)
  end

  def subject(type)
    if type == :pm
      "Hi #{greeting_name}, Here is your PM summary for #{week_beginning}!"
    else
      "Hi #{greeting_name}, here's your project schedule for #{week_beginning}!"
    end
  end

  def summary(type)
    @summary[type] ||= send("#{type}_summary")
  end

  memoize :group, :to, :from, :cc, :week_beginning, :hours_headers, :message_in_html, :ending_content_in_html

  private

  def regular_summary
    user_raw_items = schedule.user.raw_items.includes(:linked_project)
    summary = get_raw_items_with_hours(user_raw_items)

    totals = summary[:hours].transpose.map(&:sum)
    summary.merge(totals: totals)
  end

  def pm_summary
    managed_projects = schedule.user.raw_items.for_pm
    managed_raw_items = RawItem.where(project_id: managed_projects.map(&:project_id)).order("client ASC, project ASC, user_name ASC")

    get_raw_items_with_hours(managed_raw_items)
  end

  WEEK_RANGE = (0..3).freeze
  def get_raw_items_with_hours(raw_items)
    raw_items_with_hours = []
    hours = []

    raw_items.each do |item|
      whs = item.week_hours.start_from(schedule.week_start)

      if whs.present?
        raw_items_with_hours << item
        hours << hours_for_item(whs)
      end
    end

    {raw_items: raw_items_with_hours, hours: hours}
  end

  def hours_for_item(week_hours)
    WEEK_RANGE.map do |i|
      wh = week_hours.select{|wh| wh.week.to_date.to_s(:db) == (schedule.week_start + i.weeks).to_date.to_s(:db)}.first
      wh ? wh.hours.to_f : 0
    end
  end

end
