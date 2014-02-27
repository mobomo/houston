class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.text :message
      t.text :gdata_content
      t.datetime :week_start, :week_end
      t.string :status

      t.timestamps
    end
  end
end
