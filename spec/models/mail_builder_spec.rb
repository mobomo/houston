require 'spec_helper'

describe MailBuilder do

  let(:group) do
    FactoryGirl.create(:group, {
      name: 'West',
      cc: ['pm@houstonize.com'],
      from: 'no-reply@houstonize.com',
      message: "group message",
      ending_content: "group ending content"
    })
  end

  let(:user) { FactoryGirl.create :user, group: group }
  let(:schedule) { FactoryGirl.create :schedule, user: user }

  subject { MailBuilder.new(schedule) }

  context "#summary" do
    it "should generate for regular user" do
      user.stub(:current_pm?).and_return(false)
      subject.should_receive(:regular_summary)
      subject.summary(:regular)
    end

    it "should generate for PM" do
      user.stub(:current_pm?).and_return(true)
      subject.should_receive(:pm_summary)
      subject.summary(:pm)
    end
  end

  context "with customization in schedule" do
    let(:schedule) do
      FactoryGirl.create :schedule, user: user,
        cc: 'dev@houstonize.com',
        from: 'admin@houstonize.com',
        message: 'custom message',
        ending_content: 'custom ending content'
    end

    its(:cc) { should == ['dev@houstonize.com'] }
    its(:from) { should == 'admin@houstonize.com' }
    its(:message_in_html) { should == "<p>custom message</p>\n" }
    its(:ending_content_in_html) { should == "<p>custom ending content</p>\n" }
  end

  context "without customization in schedule" do
    its(:cc) { should == ['pm@houstonize.com'] }
    its(:from) { should == 'no-reply@houstonize.com' }
    its(:message_in_html) { should == "<p>group message</p>\n" }
    its(:ending_content_in_html) { should == "<p>group ending content</p>\n" }
  end

end
