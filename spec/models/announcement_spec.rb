require 'spec_helper'

describe Announcement do
  let (:project)   {FactoryGirl.create(:project)}
  let (:user)      {FactoryGirl.create :user}
  let (:user_2)    {FactoryGirl.create :user}
  let (:week_hour) {FactoryGirl.create(:week_hour, user: user)}
  let (:comment)   do
    c =FactoryGirl.build :comment, project: project, week_hour: week_hour
    c.stub(:week).and_return(Date.today)
    c
  end

  let (:last_week) {FactoryGirl.create :announcement, date: 1.week.ago}
  let (:this_week) {FactoryGirl.create :announcement, date: Date.today}
  let (:this_week_for_user) {FactoryGirl.create :announcement, date: Date.today+1, user_id: user.id}
  let (:next_week) {FactoryGirl.create :announcement, date: 1.week.from_now}
  let (:two_weeks_later) {FactoryGirl.create :announcement, date: 2.week.from_now}
  let (:jan_21) {Date.strptime("1/21/#{Date.today.year}", '%m/%d/%Y')}
  let (:dec_1) {Date.strptime("12/1/#{Date.today.year}", '%m/%d/%Y')}

  describe ".upcoming" do
    before(:each) {last_week; this_week; next_week; two_weeks_later; this_week_for_user}
    it 'should include only this and next week announcements' do
      Announcement.upcoming.collect(&:id).should =~ [next_week.id, this_week.id]
    end

    it 'should include user announcements' do
      Announcement.upcoming(user).collect(&:id).should =~ [next_week.id, this_week_for_user.id, this_week.id]
    end

    it 'should include others birthday and anniversary' do
      birthday = FactoryGirl.create :announcement, date: Date.today+1, user_id: user.id, category: Announcement::BIRTHDAY
      anniversary = FactoryGirl.create :announcement, date: Date.today+1, user_id: user.id, category: Announcement::ANNIVERSARY
      Announcement.upcoming(user).collect(&:id).should =~
        [next_week.id, this_week_for_user.id, this_week.id, birthday.id, anniversary.id]
    end

    it 'should not include reminder for others' do
      announcement = FactoryGirl.create :announcement, date: Date.today+1, user_id: user.id, category: Announcement::REMINDER
      Announcement.upcoming(user).collect(&:id).should =~
        [next_week.id, this_week_for_user.id, this_week.id, announcement.id]
    end

    it 'should sort announcements in descending order' do
      Announcement.upcoming(user).collect(&:id).should == [next_week.id, this_week_for_user.id, this_week.id]
    end
  end

  describe ".reset_announcements_from_comments" do
    before { Comment.stub(:all).and_return([comment]) }

    it "should not create duplicated announcements when called multiple times" do
      comment.text = 'birthday 1/21'

      Announcement.reset_announcements_from_comments
      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
    end

    it "should create birthday announcement" do
      comment.text = 'birthday 1/21'

      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
      Announcement.last.text.should == "Happy Birthday #{user.name}"
      Announcement.last.date.should == jan_21
    end

    it "should create anniversary announcement" do
      comment.text = 'joined 1/21'

      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
      Announcement.last.text.should == "Happy Anniversary #{user.name}"
      Announcement.last.date.should == jan_21
    end

    it "should create reminder announcement" do
      comment.text = 'reminder 12/1 blog post due'

      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
      Announcement.last.text.should == "blog post due"
      Announcement.last.date.should == dec_1
    end

    it "should create project kickoff announcement" do
      comment.text = 'kick-off 1/21'

      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
      Announcement.last.text.should == "#{project.name} Kick-off"
      Announcement.last.date.should == jan_21
    end

    it "should create project deliver announcement" do
      comment.text = 'delivery 12/1'

      Announcement.reset_announcements_from_comments
      Announcement.count.should == 1
      Announcement.last.text.should == "#{project.name} Live Date"
      Announcement.last.date.should == dec_1
    end
  end

  describe '.create_announcement_for_comment' do
    before { Comment.stub(:all).and_return([comment]) }

    it 'should create announcement for comment with date' do
      comment.text = "delivery 1/21"
      Announcement.create_announcement_for_comment(comment, comment.type).date.should == Date.new(Time.now.year,1,21)
    end

    it 'should return nil for comment without date' do
      Announcement.create_announcement_for_comment(comment, comment.type).should be_nil
    end

    it 'should return nil without category' do
      comment.text = "delivery 1/21"
      Announcement.create_announcement_for_comment(comment, nil).should be_nil
    end
  end

end
