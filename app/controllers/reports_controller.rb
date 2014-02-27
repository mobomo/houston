class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @report = Report.new(params[:skill], params[:team])

    @skills = RawItem.select("DISTINCT skill").order("skill").collect(&:skill).reject{|s| s.include?("(")}
    @teams = %w(UX Eng PM)

    @last_update = PaperTrail::Version.last.try(:created_at) || Import.last_time
  end

end
