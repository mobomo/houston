class CreateDocAuths < ActiveRecord::Migration
  def change
    create_table :doc_auths do |t|
      t.string :key
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
