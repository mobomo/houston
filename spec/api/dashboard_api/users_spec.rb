require 'spec_helper'

describe DashboardAPI::Users do
  include Rack::Test::Methods
  before (:each) {
    env 'rack.session', {'user_id' => 1}
  }
  #let (:active) {FactoryGirl.create(:user, :active)}
  #let (:inactive) {FactoryGirl.create(:user, :inactive)}
  let (:rails_dev) {FactoryGirl.create(:user, :rails_dev)}
  let (:js_dev) {FactoryGirl.create(:user, :js_dev)}

  describe "GET /api/users" do
    it "returns an empty array of users" do
      get "/api/users"
      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 0
    end
    describe 'with skill parameter' do
      before(:each) {rails_dev; js_dev}
      it "returns an array of rails devs" do
        get "/api/users", {skill: 'Rails'}
        last_response.status.should == 200
        users = JSON.parse(last_response.body)
        users.size.should == 1
        users.first["id"].should == rails_dev.id
      end
      it "returns an empty array when no skill matches" do
        get "/api/users", {skill: 'PHP'}
        last_response.status.should == 200
        users = JSON.parse(last_response.body)
        users.size.should == 0
      end

    end
    describe 'with group parameter' do
      before(:each) {rails_dev}
      it "returns an array of users in the group" do
        get "/api/users", {group: rails_dev.group.name}
        last_response.status.should == 200
        users = JSON.parse(last_response.body)
        users.size.should == 1
        users.first["id"].should == rails_dev.id
      end
      it "returns an empty array when no group matches" do
        get "/api/users", {skill: 'WoW'}
        last_response.status.should == 200
        users = JSON.parse(last_response.body)
        users.size.should == 0
      end
    end
  end
end