class AddDeletedAtToRawItems < ActiveRecord::Migration
  def change
    add_column :raw_items, :deleted_at, :time
  end
end
