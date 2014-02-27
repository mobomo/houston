module DashboardAPI
  class Projects < Base
    desc "list projects"
    params do
      optional :active, type: Boolean, desc: "filter for active/inactive projects"
      optional :internal, type: Boolean, desc: "filter for client or internal projects"
      optional :start_at, type: Date, desc: "the start date of project range"
      optional :end_at, type: Date, desc: "the end date of project range"
      optional :user_id, type: String, desc: "projects for the user_id"
      optional :group, type: String, desc: "projects for users in the group"
      optional :team, type: String, desc: "projects for users in the team"
    end
    get :projects, :jbuilder => 'projects' do
      @projects = Project.scoped
      @projects = scope_by_internal_or_external @projects
      @projects = scope_by_date_range @projects
      @projects = scope_by_active @projects
      @projects = scope_by_team @projects
      @projects = scope_by_group @projects
      @projects = scope_by_user @projects
      @projects
    end

    helpers do
      def scope_by_internal_or_external(projects)
        return projects if params.internal.nil?
        params.internal ? projects.internal : projects.external
      end

      def scope_by_date_range(projects)
        start_at  = params.start_at || 4.weeks.ago.beginning_of_week
        end_at    = params.end_at   || 20.weeks.from_now.end_of_week

        projects.intersect_with start_at, end_at
      end

      def scope_by_active(projects)
        return projects unless params.active
        projects.select(&:has_active_worker?)
      end

      def scope_by_team(projects)
        return projects unless params.team
        projects.select {|project| project.week_hours.for_team(params.team).any? }
      end

      def scope_by_group(projects)
        return projects unless params.group

        group = Group.find_by_name(params.group)
        projects.select {|project| project.week_hours.for_group(group.id).any? }
      end

      def scope_by_user(projects)
        user = User.find_by_id params.user_id
        return projects unless user

        projects.select {|project| project.week_hours.for_user(user.id).any? }
      end
    end

  end
end
