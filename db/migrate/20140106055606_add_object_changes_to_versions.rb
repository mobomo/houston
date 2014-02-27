class AddObjectChangesToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :object_changes, :string
  end
end
