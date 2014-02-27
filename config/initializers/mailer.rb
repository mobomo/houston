if Rails.env.test? && AppSettings.table_exists?
  Configuration::Mailer.settings =
    {
      host: '',
      port: '',
      user_name: '',
      password: '',
      from: 'test@houstonize.com',
      scheduler_email: 'test@houstonize.com',
    }
else
  Configuration::Mailer.configure_mailer if AppSettings.table_exists?
end