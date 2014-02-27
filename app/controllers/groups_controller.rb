class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_users_for_select
  load_and_authorize_resource
  respond_to :html

  def index
    @groups = Group.all
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = 'Group was successfully created'
    end

    respond_with @group
  end

  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated'
    end
    redirect_to groups_path
  end

  def destroy
    @group.destroy
    respond_with @group
  end

  protected

    def load_users_for_select
      @users_for_select = User.order("name ASC").collect{|c| [c.name, c.email] if not c.email.blank?}.uniq.compact
    end

end
