module ApplicationHelper

  def render_summary_table(builder, type=nil)
    type ||= (builder.schedule.user.current_pm? ? :pm : :regular)
    summary = builder.summary(type)

    if summary[:raw_items].present?
      render "mailer/#{type}_table", builder: builder
    else
      render 'mailer/no_schedule'
    end
  end

  def project_hours_summary(project_hours)
    return 'TBD' if project_hours.blank?
    project_hours.map {|ph| "#{ph[:pname]} (#{ph[:hours]})" }.join(', ')
  end

  def next_week_dates
    next_week = Date.today + 7.days
    start_date = next_week.beginning_of_week.strftime("%m/%d")
    end_date = next_week.end_of_week.strftime("%m/%d")
    "#{start_date} - #{end_date}"
  end

  def setup_path?
    controller_name == 'settings' && action_name == 'setup'
  end
  
  def feedback_configured?
    ::Configuration::Feedback.configured?
  end
end
