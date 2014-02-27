require 'spec_helper'

describe DashboardConfig do
  let (:invalid_config) { DashboardConfig.new}
  let (:valid_config) { DashboardConfig.new({client_id: 'client_id', client_secret: 'client_secret', email: 'me@example.com'}) }

  after (:each) do
    Rails.cache.clear
  end

  describe "#save" do
    it 'should return false for invalid config' do
      invalid_config.save.should == false
    end

    it 'should return true for valid config' do
      valid_config.save.should == true
    end

    it 'should set google client id' do
      valid_config.save
      AppSettings.google_client_id.should == "client_id"
    end

    it 'should set google client secret' do
      valid_config.save
      AppSettings.google_client_secret.should == "client_secret"
    end

    it 'should create the super admin user with the supplied email' do
      valid_config.save
      User.find_by_email_and_role('me@example.com', 'SuperAdmin').should_not be_nil
    end
  end
end