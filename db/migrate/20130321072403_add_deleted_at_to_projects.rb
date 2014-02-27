class AddDeletedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :deleted_at, :time
  end
end
