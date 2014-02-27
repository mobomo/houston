class AddCurrentToDocAuths < ActiveRecord::Migration
  def change
    add_column :doc_auths, :current, :boolean

  end
end
