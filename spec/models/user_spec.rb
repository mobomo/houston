require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    @east_group = Group.find_by_name("East") || FactoryGirl.create(:group, name: "East")
    @west_group = Group.find_by_name("West") || FactoryGirl.create(:group, name: "West")
  end

  describe "#in_east_team?" do
    before(:each) do
      user.group = @east_group
    end

    it "should return return true when in east group" do
      user.in_east_team?.should == true
    end
  end

  describe "#in_west_team?" do
    before(:each) do
      user.group = @west_group
    end

    it "should return true when in west group" do
      user.in_west_team?.should == true
    end
  end

  describe "#in_no_team?" do
    before(:each) do
      user.group = FactoryGirl.create(:group, name: "None")
      user.email = ''
    end

    it "should be true when in west/east groups and with email" do
      user.group = @east_group
      user.email = 'pm@houstonize.com'
      user.in_no_team?.should == false
    end
  end

  describe "#first_name" do
    it "should return nil when name is blank" do
      user.name = ''
      user.first_name.should == nil
    end

    it "should return right first name" do
      user.name = 'Patti Chan'
      user.first_name.should == "Patti"
    end
  end

  describe "#current_pm?" do
    it "should return false when user dont have PM skill" do
      user.current_pm?.should == false
    end

    it "should return true when user have PM skill" do
      RawItem.create(skill: "PM", user_id: user.id)
      user.current_pm?.should == true
    end
  end

  describe "#this_week_pto" do
    it "should return nil when user dont have pto this week" do
      user.this_week_pto.should be_empty
    end

    it "should return weekhour when user have pto this week" do
      @project   = FactoryGirl.create(:project, name: Project::PTO_NAME, client: "Client A")
      @raw_item  = FactoryGirl.create(:raw_item, user_id: user.id, client: "Client A", project: Project::PTO_NAME, project_id: @project.id, user_name: "Employee A", status: 'Booked')
      @week_hour = FactoryGirl.create(:week_hour, raw_item_id: @raw_item.id, hours: '24.0', week: (Time.zone.end_of_current_week), user_id: user.id)
      user.this_week_pto.first.id.should == @week_hour.id
    end
  end

end
