class AddManualToImports < ActiveRecord::Migration
  def change
    add_column :imports, :manual, :boolean, :default => false
  end
end
