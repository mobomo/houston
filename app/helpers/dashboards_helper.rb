module DashboardsHelper

  MyScheduleDropdownConfig = [
    # [text_prefix, week_number - current_week_number]
    ['This Week | ', 0],
    ['Last Week | ', -1],
    ['Next Week | ', 1],
    ['Two Weeks | ', 2],
    [nil,            -2],
    [nil,            -3]
  ].freeze

  def my_schedule_dropdown_options
    current_week_number = Time.zone.current_week_number

    MyScheduleDropdownConfig.map do |(prefix, diff)|
      my_schedule_dropdown_option(prefix, current_week_number+diff)
    end
  end

  def my_schedule_dropdown_option(prefix, week_number)
    from = Time.zone.beginning_of_week(week_number)
    to   = Time.zone.end_of_week(week_number)

    text = "#{prefix}#{short_date_format from} - #{short_date_format to}"
    [text, to.strftime("%Y-%m-%d")]
  end

  def short_date_format(date)
    date.strftime("%b %-d")
  end

  def faq_entry_point_link
    # https://<your-confluence>/wiki/pages/viewpage.action?pageId=parent_id
    link_to('View all questions', Configuration::Confluence.settings[:faq_link])
  end

end
