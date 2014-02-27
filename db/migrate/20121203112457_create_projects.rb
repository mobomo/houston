class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :client
      t.string :name
      t.date :date_signed
      t.date :date_kickoff
      t.date :date_target
      t.date :date_delivered
      t.boolean :is_confirmed
    
      t.timestamps
    end

    add_column :raw_items, :project_id, :integer
    
  end
end
