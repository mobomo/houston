module DashboardAPI
  class Schedules < Base

    desc "get current user's daily schedule for specified week"
    params do
      requires :week, type: String, regexp: /^\d{4}-\d{2}-\d{2}$/, desc: "to which the returned daily schedule belongs"
    end
    get :daily_schedule do
      week = Time.zone.parse params.week
      @daily_schedule = current_user.schedules.where(week_start: week).first.try(:daily_schedule) || DailySchedule.new([])
    end

  end
end
