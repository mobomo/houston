module DashboardAPI
  class Announcements < Base
    resource :announcements do

      desc "list announcements"
      get "/", jbuilder: 'announcements' do
        @announcements = Announcement.upcoming(current_user)
      end

      desc "create announcement"
      params do
        group :announcement do
          optional :user_id, type: Integer, desc: 'user id for user specific announcement, nil for public announcement'
          requires :text, type: String, desc: 'announcement text'
          optional :category, type: String, desc: 'announcement category'
          optional :date, type: Date, desc: 'date to publish announcement'
        end
      end

      post '/', jbuilder: 'announcement' do
        @announcement = Announcement.create(params.announcement)
      end
    end
  end
end