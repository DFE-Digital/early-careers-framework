# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :registrations, controllers: {
    sessions: "users/sessions",
    confirmations: "users/confirmations",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
    get "/users/new", to: "users/registrations#new"
    post "/users/register", to: "users/registrations#create"
    get "/users/information", to: "users/registrations#info"
    post "/users/check-details", to: "users/registrations#check_details", as: :users_check_details
  end

  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  namespace :registrations do
    root to: "start#index"
    resource :account_not_found, only: :show, controller: :account_not_found, path: "/account-not-found"
    resource :question_one, only: %i[show create], controller: :question_one, path: "/question-one"
    resource :question_two, only: %i[show create], controller: :question_two, path: "/question-two"
    resource :no_decision, only: :show, controller: :no_decision, path: "/no-decision"
    resource :no_participants, only: :show, controller: :no_participants, path: "/no-participants"
    resource :school_profile, only: %i[show create], controller: :school_profile, path: "/school-profile"
    resource :user_profile, only: %i[new create], controller: :user_profile, path: "/user-profile"
    resource :verification_sent, only: :show, controller: :verification_sent, path: "/verification-sent"
    resource :school_not_eligible, only: :show, controller: :school_not_eligible, path: "/school-not-eligible"
    resource :school_registered, only: :show, controller: :school_registered, path: "/school-registered"
    resource :school_not_confirmed, only: :show, controller: :school_not_confirmed, path: "/school-not-confirmed"
  end

  namespace :admin do
    resources :suppliers, only: %i[index new]
    scope "suppliers/new" do
      post "/", controller: :suppliers, action: :receive_new, as: :new_supplier
      get "supplier-type", controller: :suppliers, action: :new_supplier_type, as: :new_supplier_type
      post "supplier-type", controller: :suppliers, action: :receive_new_supplier_type

      scope "lead-provider" do
        get "choose-cip", controller: :lead_providers, action: :choose_cip, as: :new_lead_provider_cip
        post "choose-cip", controller: :lead_providers, action: :receive_cip
        get "choose-cohorts", controller: :lead_providers, action: :choose_cohorts, as: :new_lead_provider_cohorts
        post "choose-cohorts", controller: :lead_providers, action: :receive_cohorts
        get "review", controller: :lead_providers, action: :review, as: :new_lead_provider_review
        post "/", controller: :lead_providers, action: :create, as: :create_lead_provider
        get "success", controller: :lead_providers, action: :success, as: :new_lead_provider_success
      end

      scope "delivery-partner" do
        get "choose-lps", controller: :delivery_partners, action: :choose_lead_providers, as: :new_delivery_partner_lps
        post "choose-lps", controller: :delivery_partners, action: :receive_lead_providers
        get "review", controller: :delivery_partners, action: :review_delivery_partner, as: :new_delivery_partner_review
        post "/", controller: :delivery_partners, action: :create_delivery_partner, as: :create_delivery_partner
        get "success", controller: :delivery_partners, action: :delivery_partner_success, as: :new_delivery_partner_success
      end
    end

    scope "lead-providers/:lead_provider" do
      get "/", controller: :lead_providers, action: :show_details, as: :show_lead_provider
      get "/users", controller: :lead_providers, action: :show_users, as: :show_lead_provider_users
      get "/delivery-partners", controller: :lead_providers, action: :show_dps, as: :show_lead_provider_dps
      get "/schools", controller: :lead_providers, action: :show_schools, as: :show_lead_provider_schools

      get "/edit", controller: :lead_providers, action: :edit, as: :edit_lead_provider
      post "/", controller: :suppliers, action: :update_lead_provider, as: :update_lead_provider
      resources :lead_provider_users, path: "/users"
    end

    scope "delivery-partners/:delivery_partner" do
      get "/", controller: :delivery_partners, action: :show_users, as: :show_delivery_partner
      get "/lead-providers", controller: :delivery_partners, action: :show_lps, as: :show_delivery_partner_lps
      get "/schools", controller: :delivery_partners, action: :show_schools, as: :show_delivery_partner_schools

      get "/edit", controller: :delivery_partners, action: :edit_delivery_partner, as: :edit_delivery_partner
      post "/", controller: :delivery_partners, action: :update_delivery_partner, as: :update_delivery_partner

      resources :lead_provider_users, path: "/users"
    end

    resources :supplier_users, only: %i[index new create], path: "suppliers/users"
    scope "suppliers/users/new" do
      post "/", controller: :supplier_users, action: :receive_supplier
      get "user-details", controller: :supplier_users, action: :user_details, as: :new_supplier_user_details
      post "user-details", controller: :supplier_users, action: :receive_user_details
      get "review", controller: :supplier_users, action: :review, as: :new_supplier_user_review
      get "success", controller: :supplier_users, action: :success, as: :new_supplier_user_success
    end
  end

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  if Rails.env.development? || Rails.env.deployed_development?
    get "/govspeak_test", to: "govspeak_test#show"
    post "/govspeak_test", to: "govspeak_test#preview"
  end

  resource :school_search, only: %i[show create], path: "school-search", controller: :school_search

  resource :core_induction_programme, controller: :core_induction_programme, only: :show, as: "cip", path: "/core-induction-programme" do
    get "download-export", to: "core_induction_programme#download_export", as: "download_export"

    resources :years, controller: "core_induction_programme/years", only: %i[show edit update] do
      resources :modules, controller: "core_induction_programme/modules", only: %i[show edit update] do
        resources :lessons, controller: "core_induction_programme/lessons", only: %i[show edit update]
      end
    end
  end

  root to: "registrations/start#index"
end
