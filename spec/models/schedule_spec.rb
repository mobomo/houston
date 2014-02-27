require 'spec_helper'

describe Schedule do
  let(:group) { FactoryGirl.create :group }
  let(:user) { FactoryGirl.create :user, group: group }
  let(:schedule) { FactoryGirl.create :schedule, user: user }

  describe "#daily_schedule" do
    let(:data) do
      [ [["SOW1 - MVP Website1", 11.2]],
        [["SOW1 - MVP Website1", 11.2]],
        [["SOW1 - MVP Website1", 7.6], ["SOW6 - ACA Demo1", 3.6]],
        [["SOW6 - ACA Demo1", 8.4], ["SOW2 - Public Dashboard", 2.8]],
        [["SOW2 - Public Dashboard", 5.2], ["SOW1 - Microplace Replacement", 6.0]] ]
    end

    it "should be serialized into database" do
      schedule.daily_schedule = DailySchedule.new(data)
      schedule.save

      s = Schedule.find(schedule.id)
      s.daily_schedule.should be_instance_of(DailySchedule)
      s.daily_schedule.data.should == data
    end
  end

  describe "#calculate_daily_schedule" do
    let(:projects) do
      [ FactoryGirl.create(:project, name: 'SOW6 - ACA Demo1', client: 'ADP', date_target: 1.day.since),
        FactoryGirl.create(:project, name: 'SOW2 - Public Dashboard', client: 'American Bible Society', date_target: 3.days.since),
        FactoryGirl.create(:project, name: 'SOW1 - MVP Website1', client: 'High Tower', date_target: 1.day.since),
        FactoryGirl.create(:project, name: 'SOW1 - Microplace Replacement', client: 'Calvert Foundation', date_target: 1.day.since)
      ]
    end

    let(:raw_items) do
      projects.map do |project|
        FactoryGirl.create(:raw_item, project: project.name, client: project.client, user: user, user_name: user.name, project_id: project.id)
      end
    end

    subject do
      schedule.stub(:week_hours).and_return(week_hours)
      schedule.calculate_daily_schedule

      s = schedule.daily_schedule
      s && s.data.map do |day|
        day.map {|s| [s[:pname], s[:hours]] }
      end
    end

    context "for no project" do
      let(:week_hours) { [] }

      it "should be nil" do
        subject.should be_nil
      end
    end

    context "for a project with 40 hours" do
      let(:week_hours) do
        [ FactoryGirl.create(:week_hour, raw_item: raw_items[0], hours: '40.0', week: Time.zone.end_of_current_week, user: user) ]
      end

      it "should assign 8 hours to each day" do
        subject.should == [ [["SOW6 - ACA Demo1", 8.0]] ] * 5
      end
    end

    context "for two projects with different hours" do
      let(:week_hours) do
        [ FactoryGirl.create(:week_hour, raw_item: raw_items[0], hours: '24.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[1], hours: '16.0', week: Time.zone.end_of_current_week, user: user)
        ]
      end

      it "should schedule project with more hours first" do
        subject.should == [
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW2 - Public Dashboard", 8.0]],
          [["SOW2 - Public Dashboard", 8.0]]
        ]
      end
    end

    context "for two projects with same hours" do
      let(:week_hours) do
        [ FactoryGirl.create(:week_hour, raw_item: raw_items[0], hours: '20.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[1], hours: '20.0', week: Time.zone.end_of_current_week, user: user)
        ]
      end

      it "should schedule project with sooner target date" do
        subject.should == [
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW6 - ACA Demo1", 4.0], ["SOW2 - Public Dashboard", 4.0]],
          [["SOW2 - Public Dashboard", 8.0]],
          [["SOW2 - Public Dashboard", 8.0]]
        ]
      end
    end

    context "less time for many projects" do
      let(:week_hours) do
        [ FactoryGirl.create(:week_hour, raw_item: raw_items[0], hours: '8.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[1], hours: '2.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[2], hours: '16.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[3], hours: '2.0', week: Time.zone.end_of_current_week, user: user)
        ]
      end

      it "should be empty on friday (5th array)" do
        subject.should == [
          [["SOW1 - MVP Website1", 8.0]],
          [["SOW1 - MVP Website1", 8.0]],
          [["SOW6 - ACA Demo1", 8.0]],
          [["SOW1 - Microplace Replacement", 2.0], ["SOW2 - Public Dashboard", 2.0]],
          []
        ]
      end
    end

    context "overtime for many projects" do
      let(:week_hours) do
        [ FactoryGirl.create(:week_hour, raw_item: raw_items[0], hours: '12.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[1], hours: '8.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[2], hours: '30.0', week: Time.zone.end_of_current_week, user: user),
          FactoryGirl.create(:week_hour, raw_item: raw_items[3], hours: '6.0', week: Time.zone.end_of_current_week, user: user)
        ]
      end

      it "should work equal time and overtime everyday" do
        subject.should == [
          [["SOW1 - MVP Website1", 11.2]],
          [["SOW1 - MVP Website1", 11.2]],
          [["SOW1 - MVP Website1", 7.6], ["SOW6 - ACA Demo1", 3.6]],
          [["SOW6 - ACA Demo1", 8.4], ["SOW2 - Public Dashboard", 2.8]],
          [["SOW2 - Public Dashboard", 5.2], ["SOW1 - Microplace Replacement", 6.0]]
        ]
      end
    end
  end

  describe "#can_send_out?" do
    it "returns false if the user does not exist" do
      schedule.user = nil
      schedule.can_send_out?.should be_false
    end
    it "returns false if the user's group does not exist" do
      user.group = nil
      schedule.can_send_out?.should be_false
    end
    it "returns false if the user's group's display it not true" do
      user.group.display = false
      user.group.save
      schedule.can_send_out?.should be_false
    end
    it "returns false if the user is not in any team?" do
      user.stub(:in_no_team?).and_return(true)
      schedule.can_send_out?.should be_false
    end
  end

end
