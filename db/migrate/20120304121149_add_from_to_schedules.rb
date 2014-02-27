class AddFromToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :from, :string

  end
end
