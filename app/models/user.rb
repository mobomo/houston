class User < ActiveRecord::Base
  attr_accessible :name, :email, :is_pm, :group_id, :provider, :uid, :domain, :role, :harvest_token, :harvest_refresh_token, :expires_at, :refresh_at, :experiences_attributes, :skills_attributes, :logged_in

  ROLES = ['Regular', 'Admin', 'SuperAdmin']

  has_many :schedules, :dependent => :destroy
  has_many :raw_items, :dependent => :destroy
  has_many :week_hours, :dependent => :destroy
  has_many :experiences, :dependent => :destroy
  has_many :skills, :through => :experiences

  has_many :leave_requests, :dependent => :destroy
  has_many :announcements

  belongs_to :group

  accepts_nested_attributes_for :experiences, allow_destroy: true
  #accepts_nested_attributes_for :skills

  scope :east_team, joins(:group).where(:groups => { :name => "East" })
  scope :west_team, joins(:group).where(:groups => { :name => "West" })
  scope :active, joins(:group).where(:groups => {:display => true})
  scope :for_group, lambda {|group| joins(:group).where(:groups => { :name =>  group})}
  scope :with_skill, lambda {|skill| joins(:skills).where(:skills => { :name =>  skill})}

  def self.configured?
    !!User.where(role: 'SuperAdmin').find {|user| user.logged_in.present? }
  end

  def in_east_team?
    group.name == 'East'
  end

  def in_west_team?
    group.name == 'West'
  end

  def in_no_team?
    (group.name != 'West' and group.name != 'East') or email.blank?
  end

  def first_name
    nil if name.blank?
    name.split(" ").first
  end

  def current_pm?
    not raw_items.for_pm.blank?
  end

  def this_week_pto
    week_hours.current.pto
  end

  def super_admin?
    'SuperAdmin' == role
  end

  def avatar_url(size=48)
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=identicon"
  end

  def self.text_search query
    if query.present?
      where "name @@ :q", q: query
    else
      scoped
    end
  end

  # this is only needed on an open system
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
        user.email = auth['info']['email'] || ""
        user.domain = user.email.split('@').last
      end
    end
  end

  # update schedules of current week and future 2 weeks
  def update_schedules
    (0..2).each do |i|
      week_number = Time.zone.current_week_number + i

      s = schedules.find_or_create_by_week_start week_start: Time.zone.end_of_week(week_number)
      s.status = 'init' if s.status.nil?
      s.calculate_daily_schedule
      s.save
    end
  end

end
