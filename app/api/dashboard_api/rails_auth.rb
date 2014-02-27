module DashboardAPI
  class RailsAuth < Grape::Middleware::Base

    def call(env)
      if env['rack.session']['user_id'] || validate_api_token(env)
        @app.call(env)
      else
        return [401, {"Content-Type" => "text/plain"}, ["Unauthorized, please log in!"]]
      end
    end

    def validate_api_token(env)
      return false if @options[:key].nil?

      key = @options[:key].respond_to?(:call) ? @options[:key].call(env) : @options[:key]
      key && token_from_params(env) == key
    end

    def token_from_params(env)
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])["auth_token"]
    end
  end
end
