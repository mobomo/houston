class CreateRequiredSkills < ActiveRecord::Migration
  def change
    create_table :required_skills do |t|
      t.integer :level
      t.string :notes
      t.integer :skill_id
      t.integer :project_id
      t.float :years

      t.timestamps
    end
  end
end
