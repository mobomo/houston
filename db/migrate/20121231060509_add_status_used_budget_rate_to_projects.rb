class AddStatusUsedBudgetRateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :status, :string
    add_column :projects, :hours_budget, :string
    add_column :projects, :hours_used, :string
    add_column :projects, :rate, :float
  end
end
