class AddCommentToWeekHours < ActiveRecord::Migration
  def change
    add_column :week_hours, :comment, :text
  end
end
