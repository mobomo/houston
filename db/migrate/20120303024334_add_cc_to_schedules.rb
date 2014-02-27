class AddCcToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :cc, :string
  end
end
