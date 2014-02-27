class Milestone < ActiveRecord::Base
  belongs_to :project
  attr_accessible :date, :notes
  default_scope order('date ASC')
  validates :date, :presence => true
  
  def as_json(options={})
    { 
      :label => self.date.strftime("%m/%d"),
      :timestamp => self.date.to_time.to_i,
      :notes => self.notes
    }
  end
end
