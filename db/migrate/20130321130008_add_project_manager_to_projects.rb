class AddProjectManagerToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_manager, :string
  end
end
