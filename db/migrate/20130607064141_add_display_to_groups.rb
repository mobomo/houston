class AddDisplayToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :display, :boolean, :default => false
  end
end
