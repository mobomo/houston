class CreateWeekHours < ActiveRecord::Migration
  def change
    create_table :week_hours do |t|
      t.integer :raw_item_id
      t.string :week
      t.string :hours
    end
  end
end
