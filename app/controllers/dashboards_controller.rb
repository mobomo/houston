class DashboardsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :authenticate_user!

  helper_method :current_schedule

  def index
    @pending_leave_requests = LeaveRequest.pending_approval
      .exclude_for_user(current_user)
      .accessible_by(current_ability)
  end

end
