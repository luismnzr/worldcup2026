require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Devise
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "signup",
    password: "password"
  }

  # Static pages
  root "pages#home"
  get "about", to: "pages#about"
  get "terms", to: "pages#terms"

  # Shop
  resources :products, only: [ :index, :show ], path: "tienda"

  # Membership / subscription plans
  resources :subscription_plans, only: [ :index ], path: "membresia"

  # Member-only content
  resources :member_posts, only: [ :index, :show ], path: "miembros"

  # Events
  resources :events, only: [ :index, :show ], path: "eventos" do
    resources :event_registrations, only: [ :create, :destroy ], shallow: true
  end

  # Checkout & Payments
  post "checkout/subscription/:plan_id", to: "checkouts#create_subscription", as: :checkout_subscription
  post "checkout/product/:product_id", to: "checkouts#create_product", as: :checkout_product
  get "checkout/success", to: "checkouts#success", as: :checkout_success
  post "billing/portal", to: "checkouts#customer_portal", as: :customer_portal

  # Webhooks
  post "webhooks/stripe", to: "webhooks/stripe#create"

  # Profile
  get "profile", to: "profiles#show"
  get "profile/subscription", to: "profiles#subscription", as: :profile_subscription
  get "profile/billing", to: "profiles#billing", as: :profile_billing
  get "profile/orders", to: "profiles#orders", as: :profile_orders
  get "profile/orders/:id", to: "profiles#order", as: :profile_order
  get "profile/events", to: "profiles#events", as: :profile_events

  # Admin namespace
  namespace :admin do
    get "/", to: "dashboard#show", as: :dashboard
    resources :users, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
      get :search, on: :collection
      post :grant_subscription, on: :member
    end
    resources :subscription_plans
    resources :promotion_codes, only: [ :index, :new, :create ] do
      patch :toggle, on: :member
    end
    resources :events do
      resources :event_registrations, only: [ :create, :destroy ], controller: "event_registrations"
    end
    resources :products, except: [ :show ]
    resources :orders, only: [ :index, :show, :new, :create, :update ]
    resources :member_posts
    get "settings", to: "settings#show"
    patch "settings", to: "settings#update"
    get "reports", to: "reports#index"
    resources :notifications, only: [ :index ] do
      collection do
        post :mark_as_read
      end
      member do
        post :mark_one_read
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
