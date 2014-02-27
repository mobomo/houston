WeeklySchedule::Application.routes.draw do
  mount API => '/'

  resources :dashboards
  resources :experiences
  resources :skills
  resources :reports, only: [:index]
  resources :doc_auths
  resources :week_hours
  resources :raw_items, only: [:index, :destroy]
  resources :projects
  resources :leave_requests

  resources :schedules do
    collection do
      get :load_from_google
      get :batch_create
      get :check_sending_status
      get :check_importing_status
      get :weekly_send_mails
    end
  end

  resources :users do
    member do
      get :skills
    end
  end

  resources :groups

  resources :settings, :only => :index

  match 'setup', :to => 'settings#setup', :via => [:get, :post]
  get 'switch_mode', :to => 'settings#mode'
  get 'switch_user', :to => 'settings#user'

  namespace :settings do
    get 'mail_settings/edit', to: 'mail_settings#edit',   as: :edit_mail_settings
    put 'mail_settings',      to: 'mail_settings#update', as: :update_mail_settings

    put 'auto_mail/:auto_mail', to: 'mail_settings#update_auto_mail', as: :update_auto_mail

    get 'harvest/edit',          to: 'harvest#edit',          as: :edit_harvest
    put 'harvest',               to: 'harvest#update',        as: :update_harvest
    get 'harvest/refresh_token', to: 'harvest#refresh_token', as: :refresh_harvest_token

    get 'confluence/edit',          to: 'confluence#edit',          as: :edit_confluence
    put 'confluence',               to: 'confluence#update',        as: :update_confluence

    get 'google/edit',          to: 'google#edit',          as: :edit_google
    put 'google',               to: 'google#update',        as: :update_google

    get 'app_settings/edit',          to: 'app_settings#edit',          as: :edit_app_settings
    put 'app_settings',               to: 'app_settings#update',        as: :update_app_settings
  end

  root :to => 'dashboards#index'

  match '/auth/harvest/callback' => 'settings/harvest#refresh_token'
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'

end
