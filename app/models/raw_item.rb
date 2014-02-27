class RawItem < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :status, :user_id, :client, :project, :skill, :billable, :user_name, :row, :project_id, :deleted_at

  belongs_to :linked_project, :class_name => 'Project', :foreign_key => :project_id
  belongs_to :user, :touch => true
  has_many :week_hours, :dependent => :destroy

  scope :for_pm, where(:skill => "PM")
  scope :booked, where(:status => 'Booked')
  scope :pipeline, where(:status => 'Pipeline')

  FIRST_ROW    = 3
  FIRST_COLUMN = 8

  STATUS_COLUMN   = 1
  USER_COLUMN     = 3
  CLIENT_COLUMN   = 4
  PROJECT_COLUMN  = 5
  SKILL_COLUMN    = 6
  BILLABLE_COLUMN = 7

  def self.from_spreadsheet_row(sheet, row)
    return nil if sheet.cell(row, USER_COLUMN).to_s.empty?

    # get the user
    user = User.find_or_create_by_name sheet.cell(row, USER_COLUMN)
    return nil if user.nil?

    # get the raw item
    raw_item =
      user.raw_items
      .find_or_create_by_project_and_client(sheet.cell(row, PROJECT_COLUMN),
                                            sheet.cell(row, CLIENT_COLUMN))
    raw_item
      .update_attributes({
                           status:    sheet.cell(row, STATUS_COLUMN),
                           user_name: sheet.cell(row, USER_COLUMN),
                           client:    sheet.cell(row, CLIENT_COLUMN),
                           project:   sheet.cell(row, PROJECT_COLUMN),
                           skill:     sheet.cell(row, SKILL_COLUMN),
                           billable:  sheet.cell(row, BILLABLE_COLUMN),
                           row:       row.to_s
                        })

    raw_item
  end

  def self.from_spreadsheet(spreadsheet)
    (FIRST_ROW..spreadsheet.last_row).map do |row|
      raw_item = RawItem.from_spreadsheet_row spreadsheet, row
      raw_item.create_week_hours_from_spreadsheet_row spreadsheet, row
      raw_item
    end.compact
  end

  def self.init_or_update_raw_data(spreadsheet)
    WeekHour.delete_obsolete

    raw_items = RawItem.from_spreadsheet spreadsheet

    (RawItem.all - raw_items).each do |raw_item|
      raw_item.week_hours.destroy_all
      raw_item.destroy
    end
  end

  def self.update_project_linkage
    Project.select("client, name, id").all.each do |project|
      RawItem.update_all({project_id: project.id}, {project: project.name, client: project.client})
    end
  end

  def self.for_major_pm(client, project)
      pm_items = RawItem.for_pm.where(client: client, project: project)
      WeekHour.where(raw_item_id: pm_items).order('week ASC, CAST(hours as DECIMAL) DESC').first.try(:raw_item)
  end

  def create_week_hours_from_spreadsheet_row spreadsheet, row
    spreadsheet_year = spreadsheet.cell(1, FIRST_COLUMN).to_s[0..3].to_i

    current_week_column = Time.zone.current_week_number(spreadsheet_year) + FIRST_COLUMN - 1
    last_week_column    = 1 + spreadsheet.row(row).rindex {|v| v.present? }

    (current_week_column..last_week_column).each do |column|
      hours       = spreadsheet.cell(row, column)
      week_number = column - FIRST_COLUMN + 1

      if hours.to_f > 0
        week_hour = self.week_hours.find_or_create_by_week Time.zone.end_of_week(week_number, spreadsheet_year)
        week_hour.update_attributes hours: hours, user_id: user_id
      elsif hours.blank?
        week_hours.where(week: Time.zone.end_of_week(week_number)).destroy_all
      end
    end
  end

end
