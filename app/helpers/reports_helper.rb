module ReportsHelper

  def week_beginning_dates
    @week_beginning_dates ||= Dashboard.week_beginning_dates
  end

  def table_head_for_week_beginning(date, options={})
    date = date.to_s(:xshort)
    options.merge!('data-date' => date)
    content_tag(:th, date, options)
  end

  def format_hours(hour, wrapper)
    hour = hour.blank? ? 0 : hour.to_i
    css_class = "text-muted" if hour.between?(38,42)
    css_class = "text-danger" if hour < 38
    css_class = "text-danger danger" if hour.between?(0,20)
    css_class = "text-danger bad" if hour <= 0
    css_class = "text-warning" if hour > 42
    css_class = "text-warning warning" if hour > 50
    return content_tag(wrapper, hour, :class => css_class)
  end

  def projects_chart_client_select
    data = [
      ['All', 'all'],
      ['Clients', 'external'],
      ['Internal', 'internal'],
      ['Active only', 'active']
    ]
    select_tag :client, options_for_select(data, 'all')
  end

  def projects_chart_user_select
    data = [
      ['Everyone', [['Everyone', 'all']]],
      ['Team', [['Team: Eng', 'team_eng'], ['Team: PM', 'team_pm'], ['Team: UX', 'team_ux']]],
      ['User', User.active.map {|u| [u.name, "user_id_#{u.id}"] }]
    ]
    select_tag :user, grouped_options_for_select(data, 'all')
  end
end
