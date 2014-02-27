class AddUserNameToRawItems < ActiveRecord::Migration
  def change
    add_column :raw_items, :user_name, :string
    add_column :raw_items, :row, :string

  end
end
