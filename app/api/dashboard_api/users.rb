module DashboardAPI
  class Users < Base
    desc "list users"
    params do
      optional :active, type: Boolean, desc: "filter for active/inactive user"
      optional :group, type: String, desc: "filter for users within the group"
      optional :team, type: String, desc: "filter for users within the team"
      optional :skill, type: String, desc: "filter for users with the skill"
      optional :pto, type: Boolean, desc: 'filter for user with PTO this week'
    end

    get :users, jbuilder: 'users' do
      @users = User.scoped
      @users = params.active ? User.active : User.inactive unless params.active.nil?
      @users = @users.for_group(params.group) unless params.group.nil?
      @users = @users.for_team(params.team) unless params.team.nil?
      @users = @users.with_skill(params.skill) unless params.skill.nil?
      @users = @users.select { |user| user.this_week_pto.any? } if params.pto
    end
  end
end