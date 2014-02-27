module LeaveRequestsHelper
  def leave_request_status leave_request
    leave_request.approved? ? 'Approved' : 'Pending'
  end

  def leave_request_class leave_request
    leave_request_status(leave_request).downcase
  end

  def leave_request_glyph leave_request
    leave_request.approved? ? 'glyphicon-ok-sign' : 'glyphicon-question-sign'
  end

  def leave_request_date leave_request
    date  = mini_date_format(leave_request.start_date)
    date << '-'
    date << mini_date_format(leave_request.end_date)
  end

  def mini_date_format date
    format = '%-m/%-d'
    format << '/%Y' unless date.year == Time.now.year
    date.blank? ? '' : date.strftime(format)
  end
end
