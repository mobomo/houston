class Report::Pipeline

  class Row

    delegate :client, :skill, :user_name, to: :@raw_item

    def initialize(raw_item)
      @raw_item = raw_item
    end

    def week_hours
      @week_hours ||= WeekHour.report_groups_for([@raw_item], Dashboard.week_endings).values.first || []
    end

  end

  attr :rows

  def initialize
    @rows = RawItem.pipeline
      .map {|item| Row.new(item) }
      .select {|r| r.week_hours.any? {|h| h > 0} }
      .sort_by {|r| [r.client, r.user_name]}
  end

end
