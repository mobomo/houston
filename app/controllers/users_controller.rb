class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @users = User.text_search(params[:query]).order("group_id ASC")
  end

  def show
    @matched_projects = Skill.matching(@user, Project.all)
  end

  def settings
  end

  def skills
  end

  def create
    @user = User.new params[:user]
    @user.save
    respond_with @user
  end

  def update
    @user.update_attributes params[:user]
    redirect_to users_path
  end

  def destroy
    @user.destroy
    respond_with @user
  end
end
