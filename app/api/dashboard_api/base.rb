module DashboardAPI
  class Base < Grape::API
    def self.inherited(subclass)
      super
      subclass.instance_eval do
        use DashboardAPI::RailsAuth, {key: ::Configuration::DashboardAPI.key}
        format :json
        formatter :json, Grape::Formatter::Jbuilder

        helpers do
          def authenticated?
            if env['rack.session']['user_id']
              return true
            else
              error!({"error" => "Unauth 401"}, 401)
            end
          end

          def current_user
            @current_user ||= (User.find(env['rack.session']['user_id']) rescue nil)
          end
        end
      end
    end
  end
end