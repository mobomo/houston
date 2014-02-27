class CreateRawItems < ActiveRecord::Migration
  def change
    create_table :raw_items do |t|
      t.string :status
      t.integer :user_id
      t.string :client
      t.string :project
      t.string :skill
      t.boolean :billable
    end
  end
end
