class Report::ProjectPopover

  class Row
    delegate :client, :skill, :user_name, to: :@raw_item

    def initialize(raw_item)
      @raw_item = raw_item
    end

    def week_hours
      @week_hours ||= @raw_item.week_hours.where(week: Dashboard.week_endings).order('week')
    end

    def active?
      week_hours.any? {|wh| wh.hours.to_f > 0 }
    end

    def current_week_hour
      @current_week_hour ||= week_hours.current.first
    end

    def hours_of_current_week
      current_week_hour ? current_week_hour.hours.to_f : 0
    end

  end

  attr :rows

  def initialize(project)
    @project = project
    @rows = RawItem.booked.where(project_id: project.id)
      .map {|item| Row.new(item) }
      .select(&:active?)
      .sort_by! do |row|
        i = Project::ROLES.index(row.skill) || Project::ROLES.size
        [i, -row.hours_of_current_week]
      end
  end

end
