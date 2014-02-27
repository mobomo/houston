class API < Grape::API
  prefix 'api'

  mount DashboardAPI::Projects
  mount DashboardAPI::Users
  mount DashboardAPI::Pages
  mount DashboardAPI::WeekHours
  mount DashboardAPI::Announcements  
  mount DashboardAPI::Schedules

end
