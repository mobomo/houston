class RemoveCommentsFromWeekHours < ActiveRecord::Migration
  def up
    remove_column :week_hours, :comment
  end

  def down
    add_column :week_hours, :comment, :text    
  end
end
