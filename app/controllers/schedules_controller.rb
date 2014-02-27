class SchedulesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  def index
    users = get_users_for_group params[:group]
    if users.blank?
      @schedules = []
    else
      @schedules = Schedule.where(:week_start => selected_week).order("id DESC")
                     .select {|s| users.include?(s.user) }
                     .sort_by {|s| s.user.try(:name) }
    end

    @groups = Group.where(:display => true)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schedules }
    end
  end

  def edit
    @container_width = "col-md-10 col-md-offset-1"
    @users_for_select = User.active.order("name ASC").collect{|c| [c.name, c.email] if not c.email.blank?}.uniq.compact
  end


  def update
    if params[:schedule][:cc].present?
      params[:schedule][:cc] = params[:schedule][:cc].join(",")
    else
      params[:schedule][:cc] = ''
    end
    if params[:schedule][:daily_schedule].present?
      params[:schedule][:daily_schedule] = DailySchedule.new(eval(params[:schedule][:daily_schedule]))
    end
    if @schedule.update_attributes(params[:schedule])
      if params[:commit] == "Step2: Send Dev Mail" || params[:commit] == "Step3: Send PM Mail"
        begin
          @schedule.send_out
        rescue
          message = "Something wrong with mailer... please resend."
        end
        redirect_to :back, :notice => message || "Mail is successfully sent out!"
      else
        redirect_to :back, notice: 'Schedule was successfully updated.'
      end
    else
      render action: "edit"
    end
  end

  def destroy
    @schedule.destroy
		respond_with @schedule
  end

  def load_from_google
    respond_to do |format|
      format.html {
        Schedule.reload_schedules
        redirect_to schedules_path(:week => "current"), :notice => "RAW Data and Schedules are successfully updated!"
      }
      format.js {
        # inititiate manual import
        Importer.new.delay.import(true)
      }
    end
  end

  def check_importing_status
    @importing_stop = Import.last.try(:end_at).present?
  end

  def check_sending_status
    @done_sending = true || (AppSettings.done_sending_weekly_mails == 'yes')
  end

  def weekly_send_mails
    respond_to do |format|
      format.html {
        redirect_to schedules_path(:week => "current"), :notice => "All mails are successfully sent out!"
      }
      format.js {
        AppSettings.done_sending_weekly_mails == 'no'
        Schedule.delay.send_schedules_out(params[:week] == 'last' ? 'last_week' : 'this_week')
      }
    end
  end

  private

  def get_users_for_group(group)
    scope = User.joins(:group)
    return scope if group == 'all'
    return scope.where(:groups => { :name => params[:group].to_s, :display => true }) if group.present?
    scope.where(:groups => { :display => true })
  end

  def selected_week
    params[:week] == 'last' ? Time.zone.end_of_previous_week : Time.zone.end_of_current_week
  end

end
