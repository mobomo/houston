class ChangeOrderToSeqInComments < ActiveRecord::Migration
  def up
    rename_column :comments, :order, :seq
  end

  def down
    rename_column :comments, :seq, :order
  end
end
