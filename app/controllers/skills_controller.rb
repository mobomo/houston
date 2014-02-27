class SkillsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @skills = Skill.text_search(params[:query]).order('lower(name)')
  end

  def create
    if @skill.save
      flash[:notice] = 'Skill was successfully created'
    end
    respond_with @skill
  end

  def update
    if @skill.update_attributes(params[:skill])
      flash[:notice] = 'Skill was successfully updated'
    end
    respond_with @skill
  end

  def destroy
    @skill.destroy
    respond_with @skill
  end
end
