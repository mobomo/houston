class Report::Bench

  class Row
    attr :user, :raw_items
    delegate :name, :email, to: :user, prefix: true

    def initialize(user, skill, team)
      @user = user
      @current_week_number = Time.zone.current_week_number

      @raw_items = user.raw_items.order('client, project')
      skills = skill_set skill, team
      @raw_items = @raw_items.where(skill: skill_set(skill, team)) if skills
    end

    def current_week_hours
      project_week_hours['SUM'][@current_week_number - Dashboard.week_number_span.begin]
    end

    def week_hours_sum
      project_week_hours['SUM']
    end

    def each_project
      project_week_hours.each do |item, week_hours|
        next if item == 'SUM'

        yield item.client, item.project, week_hours
      end
    end

    private

    def skill_set(skill, team)
      return [skill] if skill.present?

      case team
      when "UX"
        ['UX', 'HTML/JS']
      when "Eng"
        ['Rails', 'Mobile/Eng']
      when "PM"
        ['PM', '(PM)']
      else
        nil
      end
    end

    def project_week_hours
      return @project_week_hours if @project_week_hours

      week_span = Dashboard.week_endings
      @project_week_hours = { 'SUM' => [0]*week_span.size }

      WeekHour.report_groups_for(@raw_items, week_span).each do |raw_item, week_hours|
        @project_week_hours[raw_item] = week_hours
        @project_week_hours['SUM'] = @project_week_hours['SUM'].zip(week_hours).map(&:sum)
      end

      @project_week_hours
    end

  end

  attr :rows

  def initialize(skill = nil, team = nil)
    @rows = User.active
      .map {|user| Row.new(user, skill, team) }
      .select {|row| row.raw_items.size > 0}
      .sort_by {|row| [row.current_week_hours, row.user_name] }
  end

end
