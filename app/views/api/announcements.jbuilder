json.array! @announcements do |a|
  json.(a, :id, :text, :category, :created_at, :user_id, :thumbnail)
  json.date a.date_string
end