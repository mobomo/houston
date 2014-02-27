class LeaveRequest < ActiveRecord::Base
  attr_accessible :checked_with_supervisor, :end_date, :reason_for_leaving,
                  :start_date, :approved, :approved_date, :approved_by

  validates :user_id, :start_date, :end_date,
            :reason_for_leaving, :checked_with_supervisor, presence: :true

  validate  :validate_date_range, if: :dates_present?

  belongs_to :user
  belongs_to :approver, class_name: 'User', foreign_key: 'approved_by'

  default_scope order('created_at DESC')
  scope :recent, limit(5)
  scope :pending_approval, where(approved: nil)
  scope :exclude_for_user, lambda {|user| where('user_id <> ?', user) }

  def formatted_start_date
    start_date.strftime('%m/%d/%Y') if start_date
  end

  def formatted_end_date
    end_date.strftime('%m/%d/%Y') if end_date
  end

  def approve(approver)
    update_attributes! approved: true,
                       approved_by: approver.id,
                       approved_date: Time.now
    send_out
  end

  def deny(approver)
    update_attributes! approved: false,
                       approved_by: approver.id,
                       approved_date: Time.now
    send_out
  end

  private

  def send_out
    Mailer.send_leave_request_notification(self).deliver
  end

  def dates_present?
    start_date.present? && end_date.present?
  end

  def validate_date_range
    errors[:start_date] = 'Start date is before end date' if start_date > end_date
  end
end
