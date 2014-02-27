class UserImporter

  def import
    User.update_all is_pm: false

    pm_user_ids = RawItem.for_pm
      .map(&:user_name).uniq
      .map {|name| User.find_by_name name }.compact
      .map(&:id)

    User.where(id: pm_user_ids).update_all(is_pm: true)
  end

end
