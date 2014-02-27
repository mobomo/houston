class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.integer :importance

      t.timestamps
    end
  end
end
