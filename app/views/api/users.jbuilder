json.array! @users do |user|
  json.(user, :id, :name, :email, :is_pm, :uid,
                 :provider, :domain, :status, :role)
  json.group user.group
end
