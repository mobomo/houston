# Registry for all of the application's configuration.
module Configuration
  # @return [Configuration::Harvest]
  def self.harvest
    @harvest ||= Harvest
  end
end
