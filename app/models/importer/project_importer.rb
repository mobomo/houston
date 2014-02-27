class ProjectImporter

  def import
    existing_projects = []

    raw_items.each do |raw_item|
      project = import_project_from_raw_item! raw_item
      existing_projects << project
    end

    (::Project.all - existing_projects).each(&:destroy)
  end

  def import_project_from_raw_item!(raw_item)
    project = ::Project.find_or_initialize_by_name_and_client(raw_item.project, raw_item.client)

    set_project_pm project
    set_project_dates project
    set_project_status project
    
    project.save!
    project
  end

  private

  def raw_items
    @raw_items ||= RawItem.select("DISTINCT client,project,status")
  end

  def set_project_pm(project)
    if project.project_manager.blank?
      project.project_manager = RawItem.for_major_pm(project.client, project.name).try(:user_name)
    end
  end

  def set_project_dates(project)
    hours = WeekHour.joins(:raw_item).where("raw_items.client" => project.client, "raw_items.project" => project.name).order("week")

    if hours.present?
      project.date_kickoff   = hours.first.week.to_date
      project.date_target    = hours.last.week.to_date
      project.date_delivered = project.date_target

      if !project.new_record? && project.status != "Pipeline" &&
        (project.date_kickoff_changed? || project.date_target_changed?)
        project.is_confirmed = false
      end
    end
  end

  def set_project_status(project)
    project.status = 'green' if project.new_record?
  end
end
