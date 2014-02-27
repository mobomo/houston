class Project < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail only: [:date_kickoff, :date_target, :date_delivered, :project_manager, :is_delivered, :is_confirmed]

  attr_accessible :client, :name, :date_signed, :date_kickoff, :date_target, :date_delivered, :is_confirmed, :is_delivered, :status, :hours_budget, :hours_used, :rate, :comment, :url_pmtool, :url_demo, :percent_complete, :deleted_at, :project_manager, :required_skills_attributes, :milestones_attributes

  WORK_DAY = 8
  WORK_WEEK = 40

  PTO_NAME = "Internal::Paid Time Off"

  ROLES = ['PM', 'UX', 'HTML/JS', 'Rails', 'Mobile/Eng']

  has_many :milestones, :dependent => :destroy
  has_many :required_skills
  has_many :skills, :through => :required_skills
  has_many :raw_items
  has_many :week_hours, through: :raw_items
  has_many :comments, order: 'seq asc'

  accepts_nested_attributes_for :required_skills, allow_destroy: true
  accepts_nested_attributes_for :milestones, :reject_if => :all_blank, :allow_destroy => true

  scope :active, lambda {where("date_kickoff <= ? and date_delivered >= ?", Date.today, Date.today)}
  scope :inactive, lambda {where("date_delivered < ? or date_kickoff > ?", Date.today, Date.today)}
  scope :internal, where(client: 'Internal')
  scope :external, where("client <> ? ",'Internal')
  scope :starts_between, lambda {|from, to| where("date_kickoff between ? and ?", from, to)}
  scope :ends_between, lambda {|from, to| where("date_delivered between ? and ?", from, to)}
  scope :intersect_with, lambda {|from, to| where("date_kickoff between ? and ? or date_target between ? and ? or date_delivered between ? and ?", from, to, from, to, from, to)}

  def self.pto
    Project.where(name: PTO_NAME).first
  end

  def self.by_delivery_date(date_start = 1.year.ago, date_end = Time.zone.end_of_current_week+3.weeks, delivered = false)
    order = delivered ? "date_delivered DESC" : "date_delivered"
    result = Project.where(:date_kickoff => 1.year.ago..Time.zone.now, :date_delivered => date_start..date_end, :is_delivered => delivered).order(order)
  end

  def actual_hours_deviation
    # we had planned for 300 hours to be used by this date, out of 400 hours
    # we've used 200 hours
    # but the project is only 25% done, so there's still 300 hours to go
    # even though we expected to only need 200 more hours, we actually need 300 hours
    # therefore, we are 100 hours behind schedule
    return planned_hours_remaining - actual_hours_remaining
  end

  def actual_hours_remaining
    percent_remaining * hours_budget.to_i
  end

  def budget_deviation
    # we've used up 100 hours less than we expected to by this date
    # (note: 100 hours ahead of schedule == positive 100, not -100)
    # therefore, we have SAVED 100*$175 dollars (positive cost-savings, aka "under-budget")
    actual_hours_deviation * rate.to_i
  end

  def budget_remaining
    (hours_budget - hours_used) * rate.to_i
  end

  def expectations_coordinate
    [(actual_hours_deviation/WORK_DAY).to_i,budget_deviation]
  end

  def health
    # 1-100%; should be based on:
    # - client happiness
    # - project complete
    # - (maybe) alignment with SOW, but assume some variation due to agile
    # for now, we're going to make this up via a gut check until we can quantify it
    # this can drive the red/yellow/green status
  end

  def percent_complete_calculated
    # this is a gut check. cannot be based on hours, because we could potentially
    # have under or overestimated the hours necessary to complete the task
    # should eventually be based on analyzing tickets from Jira/PT/etc.
    # i.e. storypoints_completed / storypoints_total
    # for now, we're inputting manually via a form
    percent_complete || 0.0
  end

  def percent_remaining
    return 1.0 - percent_complete_calculated
  end

  def planned_hours_deviation
    # we had planned for 300 hours to be used by this date
    # we actually only used 200 hours
    # therefore, we have 100 hours more than expected (to use up)
    # this relates to project health and percent_complete because it can mean either:
    # - we're behind schedule due to lack of resources
    # - we kicking ass and needing less time that we anticipated
    # THIS ISN'T REALLY USED - it's only here to show us how badly we estimated
    return planned_hours_expected - hours_used
  end

  def planned_hours_expected
    WeekHour.sum('CAST(week_hours.hours as DECIMAL(10,0))',
      :include => :raw_item,
      :conditions => ["raw_items.client = ? AND raw_items.project_id = ? AND week <= ?", client, id, Time.now.utc])
  end

  def planned_hours_remaining
    options = []
    options << hours_budget.to_i - planned_hours_expected.to_i # what did we expect to have left? assumes all is going as planend
    options << hours_budget.to_i - hours_used.to_i # what if we've already exceeded our budget? give actual time remaining
    return options.min
  end

  def fuzzy_due_date
    now = Date.today
    if date_target >= now.at_beginning_of_week && date_target <= now.at_end_of_week
      "This Week"
    elsif date_target >= now.next_week.at_beginning_of_week && date_target <= now.next_week.at_end_of_week
      "Next Week"
    elsif now.at_beginning_of_month == date_target.at_beginning_of_month
      "This Month"
    elsif date_target >= now.next_month.at_beginning_of_month && date_target <= now.next_month.at_end_of_month
      "Next Month"
    else
      " "
    end
  end

  def weeks_remaining
    highest_week = date_kickoff
    people = RawItem.where(:client => client, :project => name)
    people.each do |person|
      week_hour = person.week_hours.order("week DESC").first
      next if week_hour.nil?
      if week_hour.week > highest_week
        highest_week = week_hour.week
      end
    end
    highest_week.strftime("%U").to_i - Time.now.strftime("%U").to_i
  end

  def expected_progress
    hours = 0
    people = RawItem.where(:client => client, :project => name)
    people.each do |person|
      person.week_hours.where("week < ?", Time.now).each do |week|
        hours += week.hours.to_i
      end
    end
    hours
  end

  def pmtool_type
    if url_pmtool =~ /github/
      return "github"
    elsif url_pmtool =~ /unfuddle/
      return "unfuddle"
    elsif url_pmtool =~ /jspa|jql|issue/
      return "jira"
    else
      return ""
    end
  end

  def current_hours_by_teams
    whs = week_hours.current.includes(:raw_item)
    whs.inject(Hash.new{|h,k| h[k] = {}}) do |teams, wh|
      team = Dashboard.skill_to_team(wh.raw_item.skill)
      teams[team][wh.raw_item.user_name] = wh.hours.to_i
      teams
    end
  end

  def has_active_worker?
    most_hours_recent_week = WeekHour.where(raw_item_id: raw_items.booked, week: Dashboard.week_endings).order('CAST(hours as DECIMAL(10,0)) DESC').first
    most_hours_recent_week && most_hours_recent_week.hours.to_f > 0
  end

  def confirmed_at
    return unless is_confirmed?

    index = versions.rindex {|v| v.changeset['is_confirmed'] && v.changeset['is_confirmed'].last == true }
    index && versions[index]
  end

end
