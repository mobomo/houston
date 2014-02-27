class AddYearToComments < ActiveRecord::Migration
  def change
    add_column :comments, :year, :integer
  end
end
