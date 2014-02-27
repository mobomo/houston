json.array! @projects do |project|
  json.(project, :id, :client, :name, :date_kickoff, :date_delivered, :date_signed,
                 :date_target, :hours_budget, :hours_used, :is_confirmed, :is_delivered,
                 :percent_complete, :project_manager, :status, :url_demo, :url_pmtool)
  json.hours project.current_hours_by_teams
  json.comments project.comments.viewd_by(current_user) do |comment|
    json.(comment, :text)
    json.birthday comment.birthday?
    json.anniversary comment.anniversary?
    json.kickoff comment.kickoff?
    json.delivery comment.delivery?
    json.user comment.user.try(:name)
    json.week comment.week
  end
end
