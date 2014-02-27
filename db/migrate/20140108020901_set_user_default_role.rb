class SetUserDefaultRole < ActiveRecord::Migration
  def up
    change_column :users, :role, :string, default: 'Regular'
    User.where(role: nil).update_all(role: 'Regular')
  end

  def down
    change_column :users, :role, :string, default: nil
  end
end
