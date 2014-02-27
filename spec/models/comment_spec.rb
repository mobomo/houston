require 'spec_helper'

describe Comment do
  let (:project)   {FactoryGirl.create(:project)}

  let (:spreadsheet_comments) do
    [[3, 31, "Comment on Yong Gu 6/16"],
     [3, 21, "kick-off"], [3, 26, "delivery"],
     [3, 26, "kick-off"], [3, 28, "delivery"]]
  end
  let (:spreadsheet_comments_after_insertion) do
    [[2, 31, "Comment on Yong Gu 6/16"],
     [5, 21, "kick-off"], [5, 26, "delivery"],
     [5, 26, "kick-off"], [5, 28, "delivery"]]
  end

  let (:raw_item) do
    FactoryGirl.create(:raw_item, project_id: project.id, row: '1')
  end

  let (:week_hour) do
    FactoryGirl.create(:week_hour, raw_item_id: raw_item.id,
                       week: Time.zone.end_of_week(12))
  end

  describe '.reset_comments' do
    it 'should create all the comments from the spreadsheet' do
      Comment.reset_comments(spreadsheet_comments, 2013)
      Comment.count.should == 5
    end

    it 'should set the seq number all the comments' do
      Comment.reset_comments(spreadsheet_comments, 2013)
      Comment.all.collect(&:seq) == [0, 1, 2, 3, 4]
    end

    it 'should remove comments no longer exists on the spreadsheet' do
      Comment.reset_comments(spreadsheet_comments, 2013)
      Comment.count.should == 5
      Comment.reset_comments(spreadsheet_comments_after_insertion, 2013)
      Comment.count.should == 5
      Comment.all.collect(&:row).uniq =~ [2,5]
    end

    it 'should not remove comments from previous years' do
      Comment.reset_comments(spreadsheet_comments, 2013)
      Comment.count.should == 5
      Comment.reset_comments(spreadsheet_comments_after_insertion, 2014)
      Comment.count.should == 10
    end
  end

  describe '.link_project_and_week_hour' do
    before(:each) { raw_item; week_hour }

    it 'should setup project id' do
      comment = FactoryGirl.create(:comment, row: 1, col: 19)
      Comment.stub(:project_for_row).and_return(project)
      Comment.link_project_and_week_hour(nil)
      Comment.first.project_id.should == project.id
    end

    it 'should setup week_hour id' do
      comment = FactoryGirl.create(:comment, row: 1, col: 19)
      Comment.stub(:project_for_row).and_return(project)
      Comment.link_project_and_week_hour(nil)
      Comment.first.week_hour_id.should == week_hour.id
    end
  end

  describe '.update_project_dates' do
    before(:each) {raw_item; week_hour}

    it 'should setup kick off date' do
      comment =
        FactoryGirl.create(:comment, row: 1, col: 19, text: 'kick-off',
                           project_id: project.id)

      Comment.update_project_dates
      Project.first.date_kickoff.should == comment.week.to_date
    end

    it 'should setup delivery date' do
      comment =
        FactoryGirl.create(:comment, row: 1, col: 19, text: 'delivery',
                           project_id: project.id)

      Comment.update_project_dates
      Project.first.date_delivered.should == comment.week.to_date
    end

    it 'should setup target date' do
      comment =
        FactoryGirl.create(:comment, row: 1, col: 19, text: 'delivery',
                           project_id: project.id)

      Comment.update_project_dates
      Project.first.date_target.should == comment.week.to_date
    end
  end

  describe 'comment types' do
    it "should be reminder comment" do
      FactoryGirl.create(:comment, text: 'reminder test it!').should be_reminder
    end

    it "should be kickoff comment" do
      FactoryGirl.create(:comment, text: 'kick-off it').should be_kickoff
    end

    it "should be delivery comment" do
      FactoryGirl.create(:comment, text: 'delivery tarball needed').should be_delivery
    end

    it "should be birthday comment" do
      FactoryGirl.create(:comment, text: 'birthday best wishes Jan!').should be_birthday
    end

    it "should be anniversary comment" do
      FactoryGirl.create(:comment, text: 'joined this day!').should be_anniversary
    end

    it "should return type directly" do
      FactoryGirl.create(:comment, text: 'reminder test it!').type.should == 'reminder'
    end

    it "should return nil for comment without type" do
      FactoryGirl.create(:comment, text: 'what is this').type.should be_nil
    end
  end

end
