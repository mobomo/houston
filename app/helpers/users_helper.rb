module UsersHelper
  def setup_user(user)
    (Skill.all - user.skills).each do |skill|
      user.experiences.build(:skill_id => skill.id)
    end
    user.experiences.sort_by! {|e| e.skill.name }
    user
  end
end
