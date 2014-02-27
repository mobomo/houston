module SchedulesHelper

  def schedule_actions
    actions = []

    if can? :update, AppSettings
      if AppSettings.auto_mail == 'on'
        actions << ["AutoMail ON", settings_update_auto_mail_path('off'), {:method => :put, :title => "click to disable it", :class => "btn btn-success"}]
        actions << ["Config/Check Mail Content", settings_path]
      else
        actions << ["AutoMail OFF", settings_update_auto_mail_path('on'), {:method => :put, :title => "click to enable it", :class => "btn btn-danger"}]
      end
    end

    if can?(:send, Schedule) && AppSettings.auto_mail == 'off'
      actions << ["Send Schedule Emails", weekly_send_mails_schedules_path(week: params[:week]), {:confirm => "This will send current week schedules to the people in active groups!", :remote => true}]
    end

    if can? :manage, RawItem
      actions << ['Reload RAW Data Manually', load_from_google_schedules_path, {:confirm => 'This will reload all raw data, and load schedule for current week use, are you sure to continue?', :remote => true}]
    end

    # the first action must use 'btn' class
    if actions.first
      link_options = actions.first[2] || {}
      actions.first[2] = {:class => 'btn'}.merge(link_options)
    end

    actions
  end

  def review_mail(schedule, type)
    builder = MailBuilder.new schedule
    type = type.to_s

    subject = "<b>Subject:</b> #{builder.subject(type)}<br />"
    content = render_summary_table(builder, type)

    from = "<b>From: </b>#{builder.from}<br />"
    to = "<b>To: </b>#{builder.to}<br />"
    cc = "<b>CC: </b>#{builder.cc}<br />"
    devider = "<b>Mail Body:</b><br />----------------------------------------------------------------------<br />"
    mail_body = "Hi #{builder.greeting_name},<br /><br />#{builder.message_in_html}#{content}<br />#{builder.ending_content_in_html}"

    return "#{subject}#{from}#{to}#{cc}#{devider}#{mail_body}"
  end

end
