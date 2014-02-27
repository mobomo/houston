module AuthenticationHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def login!(user = nil)
      before(:each) { login(user) }
    end

    def super_admin_login!
      before(:each) { login(FactoryGirl.create(:user, :super_admin)) }
    end

    def logout!
      before(:each) { logout }
    end
  end

  def login(user = nil)
    user ||= FactoryGirl.create :user
    session[:user_id] = user.id
    @user = user
  end

  def logout
    session.delete :user_id
    @user = nil
  end

  RSpec.configure do |config|
    config.include AuthenticationHelper, type: :controller
  end

end
