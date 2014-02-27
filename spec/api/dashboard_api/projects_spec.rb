require 'spec_helper'

describe DashboardAPI::Projects do
  include Rack::Test::Methods
  before (:each) {
    env 'rack.session', {'user_id' => 1}
  }

  let(:active) {FactoryGirl.create(:project, :active)}
  let(:inactive) {FactoryGirl.create(:project, :inactive)}
  let(:internal) {FactoryGirl.create(:project, :internal)}
  let(:external) {FactoryGirl.create(:project)}
  let(:start_earlier) {FactoryGirl.create(:project, date_kickoff: 3.weeks.ago)}
  let(:end_earlier) {FactoryGirl.create(:project, date_kickoff: 30.weeks.ago, date_delivered: 10.weeks.ago)}
  let(:end_recently) {FactoryGirl.create(:project, date_kickoff: 30.weeks.ago, date_delivered: 1.weeks.ago)}
  let(:start_later) {FactoryGirl.create(:project, date_kickoff: 41.weeks.from_now)}
  let(:group) {FactoryGirl.create(:group, name: 'Fake Group')}
  let(:user) { FactoryGirl.create(:user, group_id: group.id) }

  describe "GET /api/projects" do
    it "returns an empty array of projects" do
      get "/api/projects"
      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 0
    end

    describe 'with active parameter' do
      before do
        active
        Project.any_instance.stub(:has_active_worker?).and_return(true)
      end

      describe "set to true" do
        it "returns an array of active projects" do
          get "/api/projects", {active: true}
          last_response.status.should == 200
          projects = JSON.parse(last_response.body)
          projects.size.should == 1
        end
      end
    end

    describe 'with internal parameter' do
      before(:each) {internal; external}
      describe "set to true" do
        it "returns an array of active projects" do
          get "/api/projects", {internal: true}
          last_response.status.should == 200
          projects = JSON.parse(last_response.body)
          projects.size.should == 1
          projects.first["id"].should == internal.id
        end
      end

      describe 'otherwise' do
        it "returns ab array of inactive projects" do
          get "/api/projects", {internal: false}
          last_response.status.should == 200
          projects = JSON.parse(last_response.body)
          projects.size.should == 1
          projects.first["id"].should == external.id
        end
      end
    end

    describe 'with team parameter' do
      it "returns an array of projects with team members as the worker" do
        @project   = FactoryGirl.create(:project)
        @raw_item  = FactoryGirl.create(:raw_item, user_id: user.id, project: @project.name, project_id: @project.id, user_name: "Employee A", status: 'Booked', skill: 'UX')
        @week_hour = FactoryGirl.create(:week_hour, raw_item_id: @raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id)

        get "/api/projects", {team: "UX"}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 1
      end

      it "returns an empty array when no member from the team is working for any projects" do
        get "/api/projects", {team: "Eng"}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 0
      end
    end

    describe 'with group parameter' do
      before(:each) {internal; external; group}
      it "returns an array of projects with group members as the worker" do
        @project   = FactoryGirl.create(:project)
        @raw_item  = FactoryGirl.create(:raw_item, user_id: user.id, project: @project.name, project_id: @project.id, user_name: "Employee A", status: 'Booked', skill: 'UX')
        @week_hour = FactoryGirl.create(:week_hour, raw_item_id: @raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id)

        get "/api/projects", {group: "Fake Group"}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 1
      end

      it "returns an empty array when no member from the group is working for any projects" do
        get "/api/projects", {group: "Fake Group"}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 0
      end
    end

    describe 'with user_id parameter' do
      before(:each) {internal; external}
      it "returns an array of projects with user as the worker" do
        @project   = FactoryGirl.create(:project)
        @raw_item  = FactoryGirl.create(:raw_item, user_id: user.id, project: @project.name, project_id: @project.id, user_name: "Employee A", status: 'Booked', skill: 'UX')
        @week_hour = FactoryGirl.create(:week_hour, raw_item_id: @raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id)
        get "/api/projects", {user_id: user.id}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 1
      end

      it "returns an empty array user is not working for any projects" do
        get "/api/projects", {user_id: user.id}
        last_response.status.should == 200
        projects = JSON.parse(last_response.body)
        projects.size.should == 0
      end
    end

    describe 'without range parameters' do
      before(:each) {end_earlier; end_recently; start_earlier; start_later}
      describe "set to default" do
        it "returns an array of this week's projects" do
          get "/api/projects"
          last_response.status.should == 200
          projects = JSON.parse(last_response.body)
          projects.size.should == 2
          projects.collect{|p| p['id']}.should == [end_recently.id, start_earlier.id]
        end
      end

      describe 'otherwise' do
        it "returns ab array of next week's projects" do
          get "/api/projects", {start_at: 1.week.from_now, end_at: 42.week.from_now}
          last_response.status.should == 200
          projects = JSON.parse(last_response.body)
          projects.size.should == 1
          projects.first["id"].should == start_later.id
        end
      end
    end
  end
end
