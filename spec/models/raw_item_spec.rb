require 'spec_helper'

describe RawItem do

  context ".for_major_pm" do
    let(:item1) { FactoryGirl.create(:raw_item, client: 'Foo', project: 'Bar', user_name: 'First') }
    let(:item2) { FactoryGirl.create(:raw_item, client: 'Foo', project: 'Bar', user_name: 'Second') }

    it "should choose the ealier for those begin at different time" do
      item1.week_hours.create! week: Time.zone.end_of_week(2)
      item2.week_hours.create! week: Time.zone.end_of_week(1)

      RawItem.for_major_pm('Foo', 'Bar').should == item2
    end

    it "should choose the one has more hours for those begin the same time " do
      item1.week_hours.create! week: Time.zone.end_of_week(1), hours: "8.0"
      item2.week_hours.create! week: Time.zone.end_of_week(1), hours: "20.0"

      RawItem.for_major_pm('Foo', 'Bar').should == item2
    end
  end

end
