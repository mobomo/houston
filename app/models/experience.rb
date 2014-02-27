class Experience < ActiveRecord::Base
  attr_accessible :level, :notes, :skill_id, :user_id, :years

  belongs_to :user
  belongs_to :skill
end
