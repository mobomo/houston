require 'spec_helper'

describe DashboardsController do
	login!
	let!(:import) { FactoryGirl.create :import }

	describe "GET 'index'" do
		before do
			get :index
		end
		it { should respond_with :success }
		it { should render_template :index }
	end
end

