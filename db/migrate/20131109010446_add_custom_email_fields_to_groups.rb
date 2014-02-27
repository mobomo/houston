class AddCustomEmailFieldsToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :from, :string
    add_column :groups, :cc, :text
    add_column :groups, :message, :text
    add_column :groups, :ending_content, :text

    west_group = Group.find_by_name('West')
    if west_group
      west_group.update_attributes({
        cc: AppSettings.west_cc,
        from: AppSettings.west_from,
        message: AppSettings.west_message,
        ending_content: AppSettings.west_ending_content
      })
    end
    east_group = Group.find_by_name('East')
    if east_group
      east_group.update_attributes({
        cc: AppSettings.east_cc,
        from: AppSettings.east_from,
        message: AppSettings.east_message,
        ending_content: AppSettings.east_ending_content
      })
    end
  end

  def down
    remove_column :groups, :from
    remove_column :groups, :cc
    remove_column :groups, :message
    remove_column :groups, :ending_content
  end
end
