desc "Fetch google RAW each day"
task :daily_pull_raw_data => :environment do
  puts "start fetching data....."
  Importer.new.import
  Schedule.reload_schedules
  puts "done."
end

desc "Check if it needs to send all schedules out"
task :daily_check_or_send_schedules => :environment do
  puts "start to check the DATE."
  if AppSettings.auto_mail == 'on' and Time.now.wday == 0
    Schedule.send_schedules_out
  end
  puts "done."
end

desc "Send project date change notifications"
task :send_daily_project_date_change_notifications => :environment do
  # A hash of hashes of arrays
  project_changes = Hash.new {|h, k|
    h[k] = Hash.new {|hh, kk| hh[kk] = []}
  }

  versions = PaperTrail::Version.where('item_type = ? AND event = ? AND created_at > ?', 'Project', 'update', 1.day.ago)
  versions.each do |version|
    if version.changeset.has_key?('date_target')
      project = version.item
      pm = User.find_by_name project.project_manager
      if pm && !project.is_confirmed
        project_changes[pm][project].push version.changeset
      end
    end
  end

  project_changes.each do |pm, changesets|
    Mailer.project_date_change_notification(pm, changesets).deliver
  end
end

require 'harvest_gateway'
desc "Refresh harvest token"
task :refresh_harvest_token => :environment do
  User.where(role: 'SuperAdmin').find_each do |user|
    if user.harvest_token &&
      user.harvest_refresh_token &&
      (Time.now < user.expires_at) &&
      (user.refresh_at + 17.hours) > Time.now
      hg = HarvestGateway.new user.harvest_token, user
      response = hg.refresh_token
      puts response
    else
      Mailer.send_token_notification
    end
  end
end

desc "Import project used hours from harvest"
task :import_harvest_hours => :environment do
  user = User.where(["role = ? and harvest_token is not null", 'SuperAdmin']).first
  if user
    hg = HarvestGateway.new user.harvest_token
    response = hg.get("/projects")
    if projects_json = response['result']
      projects_json.each do |project_json|
        next unless project_json['project']['billable']
        name = project_json['project']['name']
        project_id = project_json['project']['id']
        project = Project.find_by_name(name)
        next if project.nil?
        project.update_attributes({hours_budget: project_json['project']['budget']})
        from = project.date_kickoff || 1.years.ago.to_date
        entries_result = hg.get("/projects/#{project_id}/entries", { from: from.strftime("%Y%m%d"), to: Date.today.strftime("%Y%m%d")})
        if entries_json = entries_result['result']
          hours_used = entries_json.map {|e| e['day_entry']['hours']}.sum
          project.update_attributes({hours_used: hours_used.to_i.to_s})
        end
      end
    end
  end
end
