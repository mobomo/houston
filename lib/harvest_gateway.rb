class HarvestGateway

  HARVEST_API_HOST = "https://api.harvestapp.com"

  def initialize(token, user = nil, options = {})
    @access_token = token
    @user         = user
    @config       = options.fetch(:config) { Configuration.harvest }
  end

  #
  # all projects:
  # url: '/projects'
  # filters:
  #   /projects?client_id=1234
  #   /projects?updated_since=2010-09-25+18%3A30 # "2010-09-25 18:30"
  #
  # show project:
  # url: '/projects/1234'
  #
  # all clients:
  # url: '/clients'
  # filters:
  #   /clients?updated_since=2010-09-25+18%3A30 # "2010-09-25 18:30"
  # show client:
  # url: '/clients/1234'
  #

  # project entries:
  # url: '/projects/1234/entries
  # filters:
  #   from,to(required): /projects/#{project_id}/entries?from=YYYYMMDD&to=YYYYMMDD
  # Usage:
  #   get('/proejcts/1234/entries', {from: '20130101', to: '20131201'})
  #

  def get(section, params={})
    url = "#{HARVEST_API_HOST}#{section}"
    begin
      response = RestClient.get url, base_options(params)
      { 'result' => JSON.parse(response) }
    rescue => e
      { 'error' => e.response }
    end
  end

  def refresh_token
    error = { 'error' => e.response }
    return error unless @config.configured?

    token_url = "#{HARVEST_API_HOST}/oauth2/token"
    params = {
      refresh_token: @user.harvest_refresh_token,
      client_id:     @config.identifier,
      client_secret: @config.secret,
      grant_type:    "refresh_token"
    }
    options = {
      content_type: "application/x-www-form-urlencoded",
      accept: 'json'
    }
    begin
      response = RestClient.post token_url, params, options
      result = JSON.parse(response)
      @user.update_attributes({
        harvest_token: result['access_token'],
        harvest_refresh_token: result['refresh_token'],
        refresh_at: Time.now
      })
      { 'result' => result }
    rescue => e
      error
    end
  end

  private

    def base_options(extra_params={})
      options = {
        params: { access_token: @access_token }.merge(extra_params),
        accept: 'json'
      }
    end

end
