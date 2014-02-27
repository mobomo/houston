class LeaveRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :cleanup_params, only: [:create, :update]
  load_and_authorize_resource except: [:index]

  def index
    @recent_leave_requests = current_user.leave_requests.recent.accessible_by(current_ability)
    @pending_leave_requests = LeaveRequest.pending_approval.exclude_for_user(current_user).accessible_by(current_ability)
  end

  def edit
  end

  def show
  end

  def create
    @leave_request.user = current_user
    if @leave_request.save
      redirect_to :back, notice: 'Got it! Hold tight while we make your leave request happen.'
    else
      render :new
    end
  end

  def update
    if params.has_key?(:approve)
      @leave_request.approve(current_user)
      redirect_to leave_requests_url, notice: 'Leave request approved'
    elsif params.has_key?(:deny)
      @leave_request.deny(current_user)
      redirect_to leave_requests_url, notice: 'Leave request denied'
    elsif params.has_key?(:delete) && current_user == @leave_request.user
      @leave_request.destroy
      redirect_to leave_requests_url, notice: 'Leave request withdrawn'
    else
      if @leave_request.update_attributes(params[:leave_request])
        redirect_to leave_requests_url, notice: 'Leave request updated'
      else
        render :edit
      end
    end
  end

  def destroy
  end

  private

  def cleanup_params
    params[:leave_request][:end_date]   = clean_date params[:leave_request][:end_date]
    params[:leave_request][:start_date] = clean_date params[:leave_request][:start_date]
    params
  end

  def clean_date(date)
    date.blank? ? nil : DateTime.strptime(date, '%m/%d/%Y')
  end
end
