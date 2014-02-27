class AddPercentCompleteToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :percent_complete, :float
  end
end
