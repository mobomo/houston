require 'spec_helper'

describe Mailer do
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  let (:user) { FactoryGirl.create :user }
  let (:schedule) { FactoryGirl.create :schedule, user_id: user.id }
  let (:project) { FactoryGirl.create :project }
  let (:leave_request) { FactoryGirl.create :leave_request, approved_by: user.id }

  describe '#schedule_summary' do
    before (:each) { Mailer.schedule_summary(schedule).deliver }

    it 'should sent the email' do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it 'should set the subject prefix' do
      ActionMailer::Base.deliveries.first.subject.should =~ /^TEST:/
    end
  end

  describe '#send_pm_changed_notification' do
    before(:each) { Mailer.send_pm_changed_notification(project, 'new pm').deliver }

    it 'should sent the email' do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it 'should set the subject prefix' do
      ActionMailer::Base.deliveries.first.subject.should =~ /^TEST:/
    end
  end

  describe '#project_date_change_notification' do
    before(:each) { Mailer.project_date_change_notification(user, {}).deliver }

    it 'should sent the email' do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it 'should set the subject prefix' do
      ActionMailer::Base.deliveries.first.subject.should =~ /^TEST:/
    end
  end

  describe '#send_leave_request_notification' do
    before(:each) { Mailer.send_leave_request_notification(leave_request).deliver }

    it 'should sent the email' do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it 'should set the subject prefix' do
      ActionMailer::Base.deliveries.first.subject.should =~ /^TEST:/
    end
  end
end
