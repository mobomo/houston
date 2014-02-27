class Report

  attr :bench, :pipeline, :active, :inactive, :ended, :upcoming

  def initialize(skill, team)
    @bench = Report::Bench.new(skill, team)
    @pipeline = Report::Pipeline.new

    @active = current_projects.select(&:has_active_worker?)
    @inactive = current_projects.select(&:has_active_worker?)

    @ended = Project.by_delivery_date(3.weeks.ago, Time.zone.end_of_current_week, true)
    @upcoming = Project.where(:date_kickoff => Time.zone.end_of_current_week..(Time.zone.end_of_current_week+3.weeks)).order("date_target")
  end

  private

  def current_projects
    @current_projects ||= Project.by_delivery_date(1.year.ago, 1.year.from_now, false)
  end

end
