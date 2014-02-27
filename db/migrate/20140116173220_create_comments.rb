class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :week_hour_id
      t.text    :text
      t.integer :order
      t.timestamps
    end
  end
end
