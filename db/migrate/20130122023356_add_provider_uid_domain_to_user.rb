class AddProviderUidDomainToUser < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    add_column :users, :provider, :string
    add_column :users, :domain, :string
  end
end
