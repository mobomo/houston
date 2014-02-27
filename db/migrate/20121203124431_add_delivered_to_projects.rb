class AddDeliveredToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_delivered, :boolean, :default => false
  end
end
