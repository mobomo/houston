class SetDefaultValueForProjectIsConfirmed < ActiveRecord::Migration
  def up
    change_column :projects, :is_confirmed, :boolean, default: false
  end

  def down
    change_column :projects, :is_confirmed, :boolean
  end
end
