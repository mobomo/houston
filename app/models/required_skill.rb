class RequiredSkill < ActiveRecord::Base
  attr_accessible :level, :notes, :skill_id, :project_id, :years
  belongs_to :project
  belongs_to :skill
end
