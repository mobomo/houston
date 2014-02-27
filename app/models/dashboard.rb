class Dashboard

  SPAN = 13
  PROJECT_SPAN = 5

  class << self

    def week_number_span
      first_week = Time.zone.current_week_number-1
      last_week  = Time.zone.current_week_number + Dashboard::SPAN - 1
      first_week..last_week
    end

    def week_beginning_dates
      week_number_span.map do |week_number|
        Time.zone.beginning_of_week(week_number).to_date
      end
    end

    def week_endings
      week_number_span.map do |week_number|
        Time.zone.end_of_week(week_number)
      end
    end

    def convert_team_to_sql(team)
      case team.try(:downcase)
      when "ux"
        %W(UX HTML/JS)
      when "eng"
        %W(Rails Mobile/Eng)
      when "pm"
        %W(PM (PM))
      end
    end

    def skill_to_team(skill)
      case skill
      when *%W(PM (PM))
        "PM"
      when *%W(UX)
        "UX"
      when *%W(HTML/JS)
        "HTML/JS"
      when *%W(Rails)
        "Rails"
      when *%W(Mobile/Eng)
        "Mobile"
      when *%W(QA)
        "QA"
      else
        "Other"
      end
    end

  end

end
