class DailySchedule

  SHORT_DAY_NAMES = %w(Mon Tues Wed Thurs Fri).freeze

  attr :data

  def initialize(data)
    @data = data
  end

  def add(one_day_schedule)
    data << one_day_schedule
  end

  def present?
    data.present?
  end

  def each
    (0..4).each do |i|
      project_hours = data[i] || []
      yield i, SHORT_DAY_NAMES[i], project_hours
    end
  end

end
