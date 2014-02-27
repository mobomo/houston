class ExperiencesController < ApplicationController
  before_filter :authenticate_user!
  load_resource
  respond_to :html

  def index
    @experiences = Experience.all
  end

  def create
    @experience = Experience.new params[:experience]
    if @experience.save
      flash[:notice] = 'Experice was successfully created'
    end

    respond_with @experience
  end

  def update
    if @experience.update_attributes params[:experience]
      flash[:notice] = 'Experice was successfully updated'
    end

    respond_with @experience
  end

  def destroy
    @experience.destroy
    respond_with @experience
  end
end
