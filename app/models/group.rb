class Group < ActiveRecord::Base
  serialize :cc

  attr_accessible :name, :display, :cc, :from, :message, :ending_content

  default_scope order('display DESC')

  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :from, :presence => true

  has_many :users, :dependent => :nullify
end
