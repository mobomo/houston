class WeekHour < ActiveRecord::Base
  attr_accessible :raw_item_id, :hours, :week, :user_id, :comment

  belongs_to :raw_item
  belongs_to :user, :touch => true
  has_one    :comment

  scope :start_from, lambda { |date, span=4| where("week >= ? AND week <= ?", date, date + span.weeks) }
  scope :current, lambda { where("week = ?", Time.zone.end_of_current_week) }
  scope :for_team, lambda { |team| joins(:raw_item).where('raw_items.skill' => Dashboard.convert_team_to_sql(team))}
  scope :for_group, lambda { |group_id| joins(:user).where('users.group_id' => group_id)}
  scope :for_user, lambda { |user_id| where('user_id' => user_id)}

  scope :pto, lambda { joins(:raw_item).where('raw_items.project_id' => Project.pto.try(:id)) }

  accepts_nested_attributes_for :comment

  scope :by_raw_item_and_week, lambda {|raw_items, week_endings| includes(:raw_item).where(raw_item_id: raw_items, week: week_endings).order('week') }

  # delete all old RAW data, but only for future dates
  def self.delete_obsolete
    where("week > ?", Time.zone.end_of_current_week).destroy_all
  end

  def comment_text
    comment.try(:text_only)
  end

  def pto_date
    date = comment_text.to_s.match(/\d{1,2}\/\d{1,2}\s*-\s*\d{1,2}\/\d{1,2}/)
    date = comment_text.to_s.match(/\d{1,2}\/\d{1,2}/) if date.nil?
    date.to_s
  end

  def pto?
    raw_item.project_id && raw_item.project_id == Project.pto.try(:id)
  end

  def birthday?
    comment && comment.birthday?
  end

  def anniversary?
    comment && comment.anniversary?
  end

  def current_week?
    Time.zone.end_of_current_week == week
  end

  def self.report_groups_for(raw_items, week_endings)
    report_groups = {}
    by_raw_item_and_week(raw_items, week_endings).group_by(&:raw_item).each do |raw_item, week_hours|
      report_groups[raw_item] = week_endings.map do |week|
        wh = week_hours.find {|wh| wh.week == week}
        wh ? wh.hours.to_f : 0.0
      end
    end

    report_groups
  end

end
