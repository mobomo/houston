require 'spec_helper'

describe DashboardAPI::Schedules do
  include Rack::Test::Methods

  let(:user) { FactoryGirl.create(:user) }
  before do
    env 'rack.session', {'user_id' => user.id}
  end

  describe "GET /api/daily_schedule" do
    let(:data) do
      [ [["SOW1 - MVP Website1", 11.2]],
        [["SOW1 - MVP Website1", 11.2]],
        [["SOW1 - MVP Website1", 7.6], ["SOW6 - ACA Demo1", 3.6]],
        [["SOW6 - ACA Demo1", 8.4], ["SOW2 - Public Dashboard", 2.8]],
        [["SOW2 - Public Dashboard", 5.2], ["SOW1 - Microplace Replacement", 6.0]] ]
    end
    let(:daily_schedule) { DailySchedule.new(data) }
    let(:week) { Time.zone.end_of_current_week }

    before do
      FactoryGirl.create :schedule, user: user, week_start: week, daily_schedule: daily_schedule
    end

    it 'should return daily schedule of specified week' do
      get "/api/daily_schedule?week=#{week.strftime("%Y-%m-%d")}"

      last_response.status.should == 200
      JSON.parse(last_response.body)['data'].should == data
    end

    it 'should return empty DailySchedule if user have no schedule on certain week' do
      get "/api/daily_schedule?week=#{100.weeks.ago.strftime("%Y-%m-%d")}"

      last_response.status.should == 200
      JSON.parse(last_response.body)['data'].should == DailySchedule.new([]).data
    end

    it 'should return 400 for invalid week' do
      get "/api/daily_schedule?week=foobar"
      last_response.status.should == 400
    end

  end

end
