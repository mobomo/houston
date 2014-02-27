module DashboardAPI
  class Pages < Base
    rescue_from Savon::SOAPFault do |e|
       error_response({ message: e.to_hash[:fault][:faultstring] })
    end

    resource :pages do
      desc "fetch a question page"
      get '/question', :jbuilder => 'page' do
        @page = Page.recent_question
      end

      desc "create page"
      params do
        group :page do
          requires :title, type: String, desc: "page title"
          requires :content, type: String, desc: "page content"
        end
      end
      post '/', :jbuilder => 'page' do
        @page = Page.from_hash(params.page.to_hash.symbolize_keys!.merge(space: Page.default_space, parent_id: Page.faq_parent_id))
        @page = @page.save
      end

      desc "update page"
      params do
        group :page do
          requires :title, type: String, desc: "page title"
          requires :content, type: String, desc: "page content"
        end
      end
      put '/:id', :jbuilder => 'page' do
        @page = Page.from_hash(params.page.to_hash.symbolize_keys!.merge(space: Page.default_space, id: params.id))
        @page = @page.save
      end

      desc "delete page"
      delete '/:id', :jbuilder => 'page' do
        @page = Page.from_hash(id: params.id)
        @page.destroy
      end

      desc "list confluence pages"
      params do
        optional :query, type: String, desc: "search key words"
      end
      get "/", :jbuilder => 'pages' do
        @pages = if params.query
          Page.search params.query
        else
          Page.all
        end
      end

      desc "show page detail"
      get "/:id", :jbuilder => 'page' do
        @page = Page.find params.id
      end
    end
  end
end
