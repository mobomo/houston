# require manually rather than autoload to avoid constant naming mess
require 'importer/project_importer'
require 'importer/user_importer'

class Importer

  def initialize
  end

  def doc_auth
    @doc_auth ||= DocAuth.current_doc
  end

  def spreadsheet
    @spreadsheet ||= Roo::Google.new doc_auth.key, user: doc_auth.username, password: doc_auth.password
  end

  def import(manual=false)
    import = Import.create start_at: Time.zone.now, manual: manual

    year = spreadsheet.cell(1, RawItem::FIRST_COLUMN).to_s[0..3].to_i

    comments = get_comments_from_spreadsheet
    Comment.reset_comments(comments, year)
    RawItem.init_or_update_raw_data spreadsheet

    ProjectImporter.new.import
    RawItem.update_project_linkage
    Comment.link_project_and_week_hour spreadsheet
    Comment.update_project_dates
    UserImporter.new.import
    Announcement.reset_announcements_from_comments

    import.update_attributes end_at: Time.zone.now, success: true
  rescue Exception => e
    p e.message
    import.update_attributes end_at: Time.zone.now, success: false
  end

  private

  def get_comments_from_spreadsheet
    path = download_doc_to_path
    Roo::Excelx.new(path, comment_xpath: './xmlns:text/xmlns:t').comments
  end

  def download_doc_to_path
    path = Dir::Tmpname.make_tmpname("#{Rails.root}/tmp/raw", nil) + ".xlsx"

    drive = GoogleDrive.login(doc_auth.username, doc_auth.password)
    drive.spreadsheet_by_key(doc_auth.key).export_as_file(path, "xls")

    path
  end

end
