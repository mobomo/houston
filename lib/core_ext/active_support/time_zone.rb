module ActiveSupport
  class TimeZone

    def current_week_number(year = Time.zone.now.year)
      beginning_of_year = Time.zone.parse("#{year}-01-01")

      # wday begins from Sunday (e.g. sunday.wday = 0), but we want Sunday
      # to be the last week day, so shift = 0 for Monday, shift = 6 for
      # Sunday
      shift = (beginning_of_year.wday + 6) % 7

      ((Time.zone.now.to_date - beginning_of_year.to_date + shift) / 7).to_i + 1
    end

    def beginning_of_week(week_number)
      t = Time.zone.now.beginning_of_year.beginning_of_week + (week_number-1).weeks
      t.beginning_of_day
    end

    # week_number starts from 1, the first week of this year
    def end_of_week(week_number, year = Time.zone.now.year)
      year ||= Date.today.year
      t = Time.zone.parse("#{year}-01-01").end_of_week + (week_number-1).weeks
      t.beginning_of_day
    end

    def end_of_previous_week
      end_of_week(current_week_number-1)
    end

    def end_of_current_week
      Time.zone.now.end_of_week.beginning_of_day
    end

    def range_of_weeks_since_now(span)
      Time.zone.end_of_current_week..(Time.zone.end_of_current_week + span.weeks)
    end

  end
end
