class Settings::Base < ApplicationController
  before_filter :authenticate_user!, :require_permission

  def edit
  end

  private

  def require_permission
    authorize!(:update, AppSettings)
  end

end