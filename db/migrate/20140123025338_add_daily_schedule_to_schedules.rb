class AddDailyScheduleToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :daily_schedule, :text
  end
end
