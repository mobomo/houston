require 'spec_helper'

describe DocAuthsController do
	super_admin_login!

	let(:doc_auth) { FactoryGirl.create :doc_auth }

	describe "GET 'index'" do
		before do
			get :index
		end
		it { should respond_with :success }
		it { should render_template :index }
	end

	describe "GET 'edit'" do
		before do
			get :edit, id: doc_auth.id
		end
		it { should respond_with :success }
		it { should render_template :edit }
	end
end
