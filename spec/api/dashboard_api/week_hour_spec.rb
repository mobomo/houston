require 'spec_helper'

describe DashboardAPI::WeekHours do
  include Rack::Test::Methods
  before (:each) {
    env 'rack.session', {'user_id' => 1}
  }
  let (:user) { FactoryGirl.create(:user) }
  let (:pto) { FactoryGirl.create(:project, name: Project::PTO_NAME, client: "Client A") }
  let (:pto_raw_item) { FactoryGirl.create(:raw_item, user_id: user.id, client: "Client A", project: Project::PTO_NAME, project_id: pto.id, user_name: "Employee A", status: 'Booked') }
  let (:current_pto) { FactoryGirl.create(:week_hour, raw_item_id: pto_raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id) }
  let (:pto_in_3_weeks) { FactoryGirl.create(:week_hour, raw_item_id: pto_raw_item.id, hours: '8.0', week: (Time.zone.end_of_current_week + 3.weeks), user_id: user.id) }
  let (:pto_comment) {FactoryGirl.create(:comment, week_hour_id: current_pto.id, text: '2/12-2/22 pto text') }

  let (:project) { FactoryGirl.create(:project, name: "Other Project", client: "Client A") }
  let (:raw_item) { FactoryGirl.create(:raw_item, user_id: user.id, client: "Client A", project: "Other Project", project_id: project.id, user_name: "Employee A", status: 'Booked') }
  let (:current_week_hour) { FactoryGirl.create(:week_hour, raw_item_id: raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id) }
  let (:week_hour_in_3_weeks) { FactoryGirl.create(:week_hour, raw_item_id: raw_item.id, hours: '8.0', week: (Time.zone.end_of_current_week + 3.weeks), user_id: user.id) }

  describe "GET /api/week_hours" do
    before (:each) { current_pto; pto_in_3_weeks; current_week_hour; week_hour_in_3_weeks; pto_comment }
    it 'should return week hours for following two weeks' do

      get "/api/week_hours"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 2
      JSON.parse(last_response.body).collect{|w| w['id']}.should =~ [current_pto.id, current_week_hour.id]

    end

    it 'should return PTO week hours for following two weeks' do

      get "/api/week_hours?pto=true"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 1
      JSON.parse(last_response.body).first['id'].should == current_pto.id

    end

    it 'should display PTO dates' do

      get "/api/week_hours?pto=true"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 1
      JSON.parse(last_response.body).first['pto_date'].should == "2/12-2/22"

    end
  end

end