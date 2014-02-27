class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project_managers, :except => [:index]
  load_and_authorize_resource
  respond_to :html

  def index
    @projects = Project.all
  end

  def show
    @matched_users = Skill.matching(@project, User.all)
  end

  def create
    @project = Project.new params[:project]
    if @project.save
      flash[:notice] = 'Project was successfully created'
    end
    respond_with @project, location: dashboards_path
  end

  def edit
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated'
    end
    respond_with @project, location: projects_path
  end

  def destroy
    @project.destroy
    respond_with @project
  end

  protected

  def find_project_managers
    @project_managers = User.active.where(name: RawItem.for_pm.map(&:user_name)).map(&:name).uniq
  end

end
