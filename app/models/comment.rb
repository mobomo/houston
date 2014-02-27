class Comment < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  TYPE = %w(reminder kickoff delivery birthday anniversary).freeze
  TYPE_REGEXP = /(^reminder)|(^kick-off)|^(delivery)|^(birthday)|^(joined)/i.freeze

  attr_accessible :week_hour_id, :text, :seq, :col, :row, :project_id, :year

  belongs_to :week_hour
  belongs_to :project

  scope :viewd_by, ->(user) { ['Admin', 'SuperAdmin'].include?(user.try(:role)) ? scoped : limit(0) }

  def self.reset_comments(comments, spreadsheet_year)
    Comment.where(year: spreadsheet_year).destroy_all
    comments.each_with_index do |comment, index|
      comment_record =
        Comment.find_or_create_by_row_and_col_and_text_and_year(comment[0],
                                                         comment[1],
                                                         comment[2],
                                                         spreadsheet_year)

      comment_record.update_attributes(row: comment[0], col: comment[1],
                                       text: comment[2], seq: index)
    end
  end

  def self.link_project_and_week_hour spreadsheet
    Comment.all.each do |comment|
      project = project_for_row(spreadsheet, comment.row)
      if project
        raw_item = project.raw_items.where(row: comment.row.to_s).first
        week_hour = raw_item.week_hours.where(week: comment.week).first
        comment.update_attributes(project_id: project.try(:id), week_hour_id: week_hour.try(:id))
      end
    end
  end

  def self.update_project_dates
    comment = Comment.order('seq asc').all.find {|comment| comment.kickoff?}
    comment.project.update_attribute(:date_kickoff, comment.week) if comment && comment.project

    comment = Comment.order('seq asc').all.find {|comment| comment.delivery?}
    comment.project.update_attributes(date_target: comment.week, date_delivered: comment.week) if comment && comment.project
  end

  def self.project_for_row(spreadsheet, row)
    project_name = spreadsheet.cell(row, RawItem::PROJECT_COLUMN)
    client_name = spreadsheet.cell(row, RawItem::CLIENT_COLUMN)
    Project.find_by_name_and_client(project_name, client_name)
  end

  def user
    week_hour.try(:user)
  end

  def week
    Time.zone.end_of_week(col - RawItem::FIRST_COLUMN + 1, year)
  end

  def text_only
    text.to_s.gsub(/\n\t(.*)(\n----\n)*/,"\n")
  end

  def reminder?
    type == 'reminder'
  end

  def text_only
    text.to_s.gsub(/\n\t(.*)(\n----\n)*/,"\n")
  end

  def reminder?
    !!(text =~ /^reminder/i)
  end

  def kickoff?
    type == 'kickoff'
  end

  def delivery?
    type == 'delivery'
  end

  def birthday?
    type == 'birthday'
  end

  def anniversary?
    type == 'anniversary'
  end

  def type
    return unless text =~ TYPE_REGEXP
    matched_group_index = $~.to_a.rindex {|m| !m.nil? }
    TYPE[matched_group_index-1]
  end

  # switch rather than inheritance and type hierachies!
  def text_for_announcement
    case type
    when 'anniversary'
      "Happy Anniversary #{user.name}"
    when 'birthday'
      "Happy Birthday #{user.name}"
    when 'kickoff'
      "#{project.name} Kick-off"
    when 'delivery'
      "#{project.name} Live Date"
    when 'reminder'
      text_only.gsub(/^reminder\s+\d{1,2}\/\d{1,2}\s+/i,'')
    end
  end

  def parsed_date
    date = text.match(/\d{1,2}\/\d{1,2}/)
    date ? Date.strptime("#{date}/#{week.year}", '%m/%d/%Y') : nil
  end
  memoize :parsed_date

end
