class AddRefreshAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :refresh_at, :datetime
  end
end
