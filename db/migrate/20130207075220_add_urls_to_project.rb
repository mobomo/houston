class AddUrlsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :url_pmtool, :string
    add_column :projects, :url_demo, :string
  end
end
