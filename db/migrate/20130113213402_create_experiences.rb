class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.integer :level
      t.string :notes
      t.integer :skill_id
      t.integer :user_id
      t.float :years

      t.timestamps
    end
  end
end
