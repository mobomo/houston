class AddLoggedInToUsers < ActiveRecord::Migration
  def change
    add_column :users, :logged_in, :datetime
  end
end
