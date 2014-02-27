class DemoImporter < Importer

  def spreadsheet
    @spreadsheet ||= Roo::Excelx.new download_doc_to_path
  end

  def import(manual=false)
    super(manual)
    User.update_all(group_id: Group.first.id, role: 'SuperAdmin')
  end

  private

  def download_doc_to_path
    Rails.root.join('db', 'demo.xlsx').to_s
  end

end
