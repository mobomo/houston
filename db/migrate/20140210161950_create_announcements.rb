class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :text
      t.integer :user_id
      t.string :category
      t.date   :date
      t.timestamps
    end
  end
end
