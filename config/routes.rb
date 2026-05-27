Rails.application.routes.draw do
  get "/about", to: "pages#about", as: :about
  get "/privacy", to: "pages#privacy", as: :privacy
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root "home#index"
  get "dashboard", to: "dashboard#index", as: :dashboard
  resources :resumes, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  resources :jobs do
    resources :resumes, only: %i[ new create destroy ]
    member do
      get :ai_resume_suggestions
      patch :update_status
    end
    collection do
      get :import
      post :import
    end
  end
  resources :projects do
    collection do
      get :ai_suggestions
    end
  end

  # Personal iCal feed that users subscribe to from Google / Apple / Outlook
  get "/calendar/:token.ics", to: "calendar#show", as: :calendar_feed

  # Authenticated subscribe-URL management page
  resource :calendar_subscription, only: [ :show, :create, :destroy ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker",
    as: :pwa_service_worker,
    defaults: { format: :js }

  # Defines the root path route ("/")
  # root "posts#index"
end
