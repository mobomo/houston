class ChangeSomeFields < ActiveRecord::Migration
  def up
    remove_column :week_hours, :week
    add_column :week_hours, :week, :datetime
  end

  def down

  end
end
