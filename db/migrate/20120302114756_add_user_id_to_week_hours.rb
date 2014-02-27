class AddUserIdToWeekHours < ActiveRecord::Migration
  def change
    add_column :week_hours, :user_id, :integer

  end
end
