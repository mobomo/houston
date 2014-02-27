require 'spec_helper'

describe Project do
  context 'instance methods' do
    describe 'for lifecycle' do
      subject {
        FactoryGirl.create(:project,
                           :rate => 100,
                           :hours_budget => 100,
                           :hours_used => 80)
      }

      before {
        subject.stub(:planned_hours_expected) { 70 }
        subject.stub(:percent_complete_calculated) { 0.50 }
      }

      its(:planned_hours_remaining) {should == 20}
      its(:planned_hours_deviation) {should == -10} # not actually used in charting
      its(:actual_hours_remaining) {should == 50}
      its(:actual_hours_deviation) {should == -30}
      its(:budget_remaining) {should == 2000}
      its(:budget_deviation) {should == -3000}
      its(:expectations_coordinate) { should == [-3,-3000] }
    end
  end

  describe "#current_hours_by_teams" do
    before(:each) do
      @project   = FactoryGirl.create(:project, name: "Project A", client: "Client A")
      @user      = FactoryGirl.create(:user, name: "Employee A")
      @raw_item  = FactoryGirl.create(:raw_item, user_id: @user.id, client: "Client A", project: "Project A", project_id: @project.id, skill: "UX", user_name: "Employee A", status: 'Booked')
      @week_hour = FactoryGirl.create(:week_hour, raw_item_id: @raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week))
    end

    it "should returns workers for the project with assigned hours" do
      hours = @project.current_hours_by_teams
      hours.should == {'UX' => {'Employee A' => 24}}
    end
  end

  describe "#confirmed_at" do
    it "should return nil for unconfirmed project" do
      Project.new.confirmed_at.should be_nil
      Project.new(is_confirmed: false).confirmed_at.should be_nil
    end

    it "should return the version the project confirmed at" do
      user = FactoryGirl.create :user
      project = FactoryGirl.create :project
      PaperTrail.whodunnit = user.id

      with_versioning do
        project.update_attributes is_confirmed: true
        project.confirmed_at.whodunnit.should == user.id.to_s
      end
    end

    it "should return the user who reconfirmed the project" do
      user = FactoryGirl.create :user
      project = FactoryGirl.create :project, is_confirmed: false
      PaperTrail.whodunnit = user.id

      with_versioning do
        project.update_attributes is_confirmed: true
        project.confirmed_at.whodunnit.should == user.id.to_s
      end
    end
  end
end
