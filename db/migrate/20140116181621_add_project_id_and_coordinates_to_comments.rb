class AddProjectIdAndCoordinatesToComments < ActiveRecord::Migration
  def change
    add_column :comments, :project_id, :integer
    add_column :comments, :row, :integer
    add_column :comments, :col, :integer
  end
end
