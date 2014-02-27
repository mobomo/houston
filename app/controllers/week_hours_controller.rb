class WeekHoursController < ApplicationController
  before_filter :authenticate_user!
  load_resource
  respond_to :html

  def create
    @week_hour = WeekHour.new(params[:week_hour])
    if @week_hour.save
      flash[:notice] = 'Week hour was successfully created.'
    end
    respond_with :html
  end

  def update
    if @week_hour.update_attributes(params[:week_hour])
      flash[:notice] = 'Week hour was successfully updated.'
    end
    respond_with @week_hour
  end

  def destroy
    @week_hour.destroy
    respond_with @week_hour
  end
end
