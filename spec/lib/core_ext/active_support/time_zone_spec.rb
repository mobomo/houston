require 'spec_helper'

describe ActiveSupport::TimeZone do

  after do
    # unstub raise exception when Time.now is not stubbed.
    # so we first stub it, then we can always unstub
    Time.stub(:now)
    Time.unstub(:now)
  end

  let!(:sunday_12_01) { Time.zone.parse("2013-12-01") }
  let!(:monday_12_02) { Time.zone.parse("2013-12-02") }
  let!(:friday_12_06) { Time.zone.parse("2013-12-06") }
  let!(:sunday_12_08) { Time.zone.parse("2013-12-08") }
  let!(:monday_12_30) { Time.zone.parse("2013-12-30") }

  let!(:thursday_01_02) { Time.zone.parse("2014-01-02") }
  let!(:sunday_01_05) { Time.zone.parse("2014-01-05") }
  let!(:sunday_01_12) { Time.zone.parse("2014-01-12") }
  let!(:tuesday_01_14) { Time.zone.parse("2014-01-14") }

  it "should conform to the general equation" do
    Time.zone.end_of_current_week.to_date.should == Time.zone.end_of_week(Time.zone.current_week_number).to_date
  end

  context "#current_week_number" do
    it "should start from 1" do
      Time.stub(:now).and_return(thursday_01_02)
      Time.zone.current_week_number.should == 1
    end

    it "should be consistent for days in same week" do
      Time.stub(:now).and_return(monday_12_02)
      n1 = Time.zone.current_week_number

      Time.stub(:now).and_return(friday_12_06)
      n2 = Time.zone.current_week_number

      n1.should == n2
    end

    it "should handle different years" do
      Time.stub(:now).and_return(thursday_01_02)
      Time.zone.current_week_number(2013) == 53
    end
  end

  context "#end_of_previous_week" do
    before do
      Time.stub(:now).and_return(tuesday_01_14)
    end

    it "should return the end of previous week" do
      Time.zone.end_of_previous_week.should == sunday_01_12
    end
  end

  context "#end_of_current_week" do
    it "should always be Sunday" do
      Time.zone.end_of_current_week.wday.should == 0
    end

    context "today is Sunday" do
      before do
        Time.stub(:now).and_return(sunday_12_01)
      end

      it "should return today" do
        Time.zone.end_of_current_week.to_date.should == sunday_12_01.to_date
      end
    end

    context "today is Monday" do
      before do
        Time.stub(:now).and_return(monday_12_02)
      end

      it "should return next Sunday" do
        Time.zone.end_of_current_week.to_date.should == sunday_12_08.to_date
      end
    end

    context "edge case on end of year" do
      before do
        Time.stub(:now).and_return(monday_12_30)
      end

      it "should return the first sunday in new year" do
        Time.zone.end_of_current_week.to_date.should == sunday_01_05.to_date
      end
    end
  end

end
