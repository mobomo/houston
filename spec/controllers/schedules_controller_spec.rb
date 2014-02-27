require 'spec_helper'

describe SchedulesController do
  super_admin_login!

  describe "GET 'index'" do
    before do
      get :index
    end
    it { should respond_with :success }
    it { should render_template :index }
  end

  describe "PUT 'update'" do
    before(:each) do
      group = Group.find_by_name("West") || FactoryGirl.create(:group, name: "West")
      @user = FactoryGirl.create(:user, email: "test@foo.com", name: "foo bar", group: group)
      @schedule = FactoryGirl.create(:schedule, user_id: @user.id)
      request.env["HTTP_REFERER"] = '/'
    end

    it "should send out email when submit form with 'Step2: Send Dev Mail'" do
      put :update, commit: "Step2: Send Dev Mail", id: @schedule.id, schedule: {}
      ActionMailer::Base.deliveries.last.should_not be_nil
    end

    it "should send out email when submit form with 'Step3: Send PM Mail'" do
      @user.update_attribute(:is_pm, true)
      put :update, commit: "Step3: Send PM Mail", id: @schedule.id, schedule: {}
      ActionMailer::Base.deliveries.last.should_not be_nil
    end
  end
end
