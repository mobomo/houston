class Announcement < ActiveRecord::Base
  attr_accessible :text, :category, :date, :user_id
  belongs_to :user

  scope :between, lambda { |start_at, end_at| where("date >= :start and date <= :end or (date is null and created_at >= :start and created_at <= :end)",
                        { start: start_at, end: end_at }) }
  scope :general, -> {where("user_id is null or category <> ?", REMINDER)}

  ANNIVERSARY = 'anniversary'
  PROJECT = 'project'
  BIRTHDAY = 'birthday'
  GENERAL = 'general'
  REMINDER = 'reminder'

  class <<self
    def upcoming(user=nil)
      announcements = Announcement.general.between(Date.today.beginning_of_week.to_date, 1.week.from_now.end_of_week.to_date)
      announcements += user.announcements.between(Date.today.beginning_of_week.to_date, 1.week.from_now.end_of_week.to_date) if user
      announcements.uniq.sort_by(&:effective_date).reverse
    end

    def reset_announcements_from_comments
      Comment.all.each do |comment|
        create_announcement_for_comment comment, category_for_comment(comment)
      end
    end

    def create_announcement_for_comment(comment, category)
      find_or_create_by_user_id_and_text_and_date_and_category(
        comment.user.try(:id),
        comment.text_for_announcement,
        comment.parsed_date,
        category
      ) if category && comment.parsed_date
    end

    def category_for_comment(comment)
      return PROJECT if comment.project && %w(kickoff delivery).include?(comment.type)
      return comment.type if comment.week_hour && %w(anniversary birthday reminder).include?(comment.type)
      nil
    end
  end

  def thumbnail
    personal? ? user.avatar_url(46) : "/assets/logo.png"
  end

  def personal?
    category.present? && category != GENERAL && category != PROJECT
  end

  def date_string
    return '' unless date
    date_string = date.strftime("%b %d")
    %w(Yesterday Today Tomorrow).each_with_index do |name, index|
      date_string = "#{name} #{date_string}" if date == (Time.zone.today + index - 1).to_date
    end
    date_string
  end

  def effective_date
    (date || created_at).to_date
  end

end
