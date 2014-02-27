require 'spec_helper'

describe LeaveRequest do
  let(:leave_request) { FactoryGirl.create(:leave_request) }
  let(:super_admin) { FactoryGirl.create(:user, :super_admin) }
  let(:regular_user) { FactoryGirl.create(:user, :regular_user, id: 123) }

  describe '.approve' do
    it 'should set approved flag, approved_by and approved_date' do
      a_moment_in_time = Time.now
      Time.stub(:now).and_return(a_moment_in_time)

      leave_request.approve(super_admin)
      leave_request.approved.should be_true
      leave_request.approved_date.should eql(a_moment_in_time)
      leave_request.approved_by.should eq(super_admin.id)
    end
  end

  describe '.deny' do
    it 'should set approved flag, approved_by and approved_date' do
      a_moment_in_time = Time.now
      Time.stub(:now).and_return(a_moment_in_time)

      leave_request.deny(super_admin)
      leave_request.approved.should be_false
      leave_request.approved_date.should eql(a_moment_in_time)
      leave_request.approved_by.should eq(super_admin.id)
    end
  end

  describe 'formatted dates' do
    it 'should display start_date as m/d/y' do
      expected = leave_request.start_date.strftime '%m/%d/%Y'
      leave_request.formatted_start_date.should eq(expected)
    end

    it 'should display end_date as m/d/y' do
      expected = leave_request.end_date.strftime '%m/%d/%Y'
      leave_request.formatted_end_date.should eq(expected)
    end
  end
end
