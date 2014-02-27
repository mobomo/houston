require 'spec_helper'

describe DashboardAPI::Announcements do
  include Rack::Test::Methods
  before (:each) {
    user
    env 'rack.session', {'user_id' => user.id}
  }
  let (:user) { FactoryGirl.create(:user) }
  let (:user2) { FactoryGirl.create(:user) }
  let (:last_week) { FactoryGirl.create(:announcement, date: 1.week.ago.to_date) }
  let (:this_week) { FactoryGirl.create(:announcement, date: Date.today) }
  let (:next_week) { FactoryGirl.create(:announcement, date: 1.week.from_now.to_date) }
  let (:no_date) { FactoryGirl.create(:announcement) }
  let (:user_announcement) { FactoryGirl.create(:announcement, user_id: user.id) }
  let (:user2_announcement) { FactoryGirl.create(:announcement, user_id: user2.id) }

  describe "GET /announcements" do
    before (:each) {last_week; this_week; next_week}
    it 'should return announcements for upcoming weeks' do

      get "/api/announcements"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 2
      JSON.parse(last_response.body).collect{|w| w['id']}.should == [next_week.id, this_week.id]
    end

    it 'should include announcements with no date specified' do
      no_date
      get "/api/announcements"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 3
      JSON.parse(last_response.body).collect{|w| w['id']}.should =~ [no_date.id, next_week.id, this_week.id]
    end

    it 'should include announcements for specific user' do
      user_announcement; user2_announcement
      get "/api/announcements"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 3
      JSON.parse(last_response.body).collect{|w| w['id']}.should =~ [user_announcement.id, next_week.id, this_week.id]
    end
  end

   describe "POST /announcements" do
     it 'should create announcement' do
       post "/api/announcements", { announcement: {text: 'text'} }

       last_response.status.should == 201
       JSON.parse(last_response.body)['text'].should == 'text'
     end
   end
end