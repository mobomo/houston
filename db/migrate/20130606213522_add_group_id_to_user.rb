class AddGroupIdToUser < ActiveRecord::Migration
  # local model
  class Group < ActiveRecord::Base
    attr_accessible :name

    validates :name, :presence => true
    validates :name, :uniqueness => true
    
    has_many :users, :dependent => :nullify
  end
  
  # local model
  class User < ActiveRecord::Base
    attr_accessible :name, :email, :is_pm, :group_id, :provider, :uid, :domain, :experiences_attributes, :skills_attributes
    has_many :schedules, :dependent => :destroy
    has_many :raw_items, :dependent => :destroy
    has_many :week_hours, :dependent => :destroy
    has_many :experiences, :dependent => :destroy
    has_many :skills, :through => :experiences
    
    belongs_to :group

    accepts_nested_attributes_for :experiences, allow_destroy: true
  end
  
  def up
    add_column :users, :group_id, :integer
    
    # create groups as necessary, add users to group based on existing group_name
    User.reset_column_information
    
    users = User.find(:all)
    
    users.each do |user|
      group = Group.find_or_create_by_name(user.group_name)
      user.group = group
      user.save
    end
    
    remove_column :users, :group_name
  end
  
  def down
    add_column :users, :group_name, :string
    
    # populate group_name based on name from group model
    User.reset_column_information
    
    users = User.find(:all)
    
    users.each do |user|
      user.group_name = user.group.try(:name)
      user.save
    end
    
    remove_column :users, :group_id
  end
end
