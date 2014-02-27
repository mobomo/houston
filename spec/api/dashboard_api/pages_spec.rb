require 'spec_helper'

describe DashboardAPI::Pages do
  include Rack::Test::Methods
  before (:each) do
    env 'rack.session', {'user_id' => 1}
    Page.stub(:default_space).and_return 'TESTSPACE'
    Page.stub(:faq_parent_id).and_return '123'
  end

  let (:page) { Page.from_hash({id: 1, title: 'title', content: 'content'}) }

  describe "POST /api/pages" do
    it "calls Page to create a page in confluence" do
      Page.any_instance.should_receive(:save).and_return(page)

      post "/api/pages", {page: {title: 'title', content: 'content'}}

      last_response.status.should == 201
    end
  end

  describe "PUT /api/pages/1" do
    it "calls Page to update a page in confluence" do
      Page.any_instance.should_receive(:save).and_return(page)

      put "/api/pages/1", {page: {id: 1, title: 'new title', content: 'new content'}}

      last_response.status.should == 200
    end
  end

  describe "delete /api/pages/1" do
    it "calls Page to delete a page in confluence" do
      Page.any_instance.should_receive(:destroy)

      delete "/api/pages/1"

      last_response.status.should == 200
    end
  end

  describe "GET /api/pages" do
    it "returns an empty array of users" do
      Page.should_receive(:all).and_return([page])

      get "/api/pages"

      last_response.status.should == 200
      JSON.parse(last_response.body).count.should == 1
      JSON.parse(last_response.body).first['id'].should == 1
    end
  end

  describe "GET /api/pages/question" do
    it "returns a question page" do
      Page.should_receive(:recent_question).and_return(page)

      get "/api/pages/question"

      last_response.status.should == 200
    end
  end

  describe "GET /api/pages/1" do
    it "returns an empty array of users" do
      Page.should_receive(:find).with("1").and_return(page)

      get "/api/pages/1"

      last_response.status.should == 200
      JSON.parse(last_response.body)['id'].should == 1
    end
  end


end
