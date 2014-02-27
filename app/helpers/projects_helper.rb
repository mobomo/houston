module ProjectsHelper
  def setup_project(project)
    (Skill.all - project.skills).each do |skill|
      project.required_skills.build(:skill_id => skill.id)
    end
    project.required_skills.sort_by! {|r| r.skill.name }
    project
  end

  def confirmed_info(project)
    confirmed_at = project.confirmed_at
    project.confirmed_at.present? ? "Confirmed by #{User.find(confirmed_at.whodunnit).name}, #{distance_of_time_in_words_to_now(confirmed_at.created_at)} ago" : ''
  end

end
