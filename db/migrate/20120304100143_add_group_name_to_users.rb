class AddGroupNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :group_name, :string

  end
end
