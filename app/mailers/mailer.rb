class Mailer < ActionMailer::Base
  default from: ::Configuration::Mailer.from if ::Configuration::Mailer.configured?

  helper ApplicationHelper, MailerHelper

  def schedule_summary(schedule)
    @builder = MailBuilder.new schedule
    type = schedule.user.current_pm? ? :pm : :regular
    schedule.update_attributes(status: "sent")

    mail to: @builder.to,
         cc: @builder.cc,
         reply_to: @builder.from,
         subject: env_prefix + @builder.subject(type)
  end

  def send_pm_changed_notification(project, new_project_manager)
    @project = project
    @new_project_manager = new_project_manager
    mail to: ::Configuration::Mailer.scheduler_email,
         subject: env_prefix + "The PM in project #{project.name} is changed from #{project.project_manager} to #{new_project_manager}"
  end

  def project_date_change_notification(pm, changesets)
    @pm = pm
    @changesets = changesets

    mail to: @pm.email,
         subject: env_prefix + "The following project target dates have been changed:"
  end

  def send_leave_request_notification(leave_request)
    @leave_request = leave_request
    @status = leave_request.approved? ? 'approved!' : 'rejected.'
    @subject = env_prefix
    @subject << "#{@leave_request.formatted_start_date} - "
    @subject << "#{@leave_request.formatted_end_date} "
    @subject << "has been #{@status}"

    mail to: @leave_request.user.email,
         cc: @leave_request.approver.email,
         subject: @subject
  end

  def send_token_notification
    mail to: Configuration::Mailer.scheduler_email,
      subject: "The harvest access token will be expired, please login to renew."
  end

  private

  def env_prefix
    Rails.env.production? ? "" : "#{Rails.env.upcase}: "
  end
end
