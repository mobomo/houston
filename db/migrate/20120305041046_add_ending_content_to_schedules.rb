class AddEndingContentToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :ending_content, :text

  end
end
