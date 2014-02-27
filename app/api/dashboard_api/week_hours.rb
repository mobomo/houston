module DashboardAPI
  class WeekHours < Base
    desc "list week hours"
    params do
      optional :pto, type: Boolean, desc: 'filter for PTO week hours'
    end

    get :week_hours, jbuilder: 'week_hours' do
      @week_hours = WeekHour.start_from(Date.today, 2)
      @week_hours = @week_hours.pto if params.pto
    end
  end
end