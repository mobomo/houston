require 'securerandom'

WeeklySchedule::Application.config.secret_token =
  if Rails.env.development? || Rails.env.test?
    "022c447dbcca172c3ef05b61816e78ca3815d7c5daa6c949c9f27d6a69844870ac956bc6274fb15478b3e9f7f3b0360960a5ef6072cde8f81025f19f3b60d668"
  else
    AppSettings.app_config_secret_token ||= SecureRandom.hex(64) if AppSettings.table_exists?
  end

