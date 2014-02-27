class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :success

      t.timestamps
    end
  end
end
