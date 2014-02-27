class AddHarvestColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :harvest_token, :string
    add_column :users, :harvest_refresh_token, :string
    add_column :users, :expires_at, :datetime
  end
end
