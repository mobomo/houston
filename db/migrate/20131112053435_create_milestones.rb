class CreateMilestones < ActiveRecord::Migration
  def change
    unless table_exists? :milestones
      create_table :milestones do |t|
        t.date :date
        t.text :notes
        t.belongs_to :project

        t.timestamps
      end
      add_index :milestones, :project_id
    end
  end
end
