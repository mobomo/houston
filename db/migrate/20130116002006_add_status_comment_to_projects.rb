class AddStatusCommentToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :comment, :text
  end
end
