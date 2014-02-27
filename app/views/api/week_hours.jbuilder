json.array! @week_hours do |week_hour|
  json.(week_hour, :id, :hours, :week)
  json.current_week week_hour.current_week?
  json.birthday week_hour.birthday?
  json.anniversary week_hour.anniversary?

  json.user do
    json.(week_hour.user, :name, :email, :avatar_url)
  end

  if week_hour.pto?
    json.pto_date week_hour.pto_date
  end
end