class Import < ActiveRecord::Base
  default_scope :order => "id ASC"
  has_paper_trail on: [:create]

  attr_accessible :start_at, :end_at, :success, :manual

  def self.last_time
    last.try(:end_at) || Time.zone.at(0)
  end

  def self.last_nightly_time
    where(manual: false).last.try(:end_at) || Time.zone.at(0)
  end

end
