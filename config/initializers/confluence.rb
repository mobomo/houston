module Confluence
  logger = Logger.new Rails.root.join('log', 'confluence.log')
  logger.level = Logger::ERROR if Rails.env.production?

  Options            = {logger: logger}
  Options.merge!(pretty_print_xml: true) if Rails.env.development?

  HTTPI.logger       = logger

  ::Configuration::Confluence.connect() if AppSettings.table_exists?
end
