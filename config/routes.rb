# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :registrations, controllers: {
    sessions: "users/sessions",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
    get "/users/confirm_school", to: "users/registrations#confirm_school"
    get "/users/check_email", to: "users/registrations#start_registration"
    post "/users/check_email", to: "users/registrations#check_email"
    get "/users/register", to: "users/registrations#new"
    post "/users/register", to: "users/registrations#create"
  end

  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  namespace :admin do
    resource :dashboard, controller: :dashboard, only: :show
    resources :suppliers, only: %i[index edit update create new]
    scope "suppliers/new" do
      post "/", controller: :suppliers, action: :receive_new, as: :new_supplier
      get "supplier-type", controller: :suppliers, action: :new_supplier_type, as: :new_supplier_type
      post "supplier-type", controller: :suppliers, action: :receive_new_supplier_type

      scope "lead-provider" do
        get "choose-cip", controller: :suppliers, action: :choose_cip, as: :new_lead_provider_cip
        post "choose-cip", controller: :suppliers, action: :receive_cip
        get "choose-cohorts", controller: :suppliers, action: :choose_cohorts, as: :new_lead_provider_cohorts
        post "choose-cohorts", controller: :suppliers, action: :receive_cohorts
        get "review", controller: :suppliers, action: :review_lead_provider, as: :new_lead_provider_review
        post "/", controller: :suppliers, action: :create_lead_provider, as: :create_lead_provider
        get "success", controller: :suppliers, action: :lead_provider_success, as: :new_lead_provider_success
      end

      scope "delivery-partner" do
        get "choose-lps", controller: :suppliers, action: :choose_lead_providers, as: :new_delivery_partner_lps
        post "choose-lps", controller: :suppliers, action: :receive_lead_providers
        get "review", controller: :suppliers, action: :review_delivery_partner, as: :new_delivery_partner_review
        post "/", controller: :suppliers, action: :create_delivery_partner, as: :create_delivery_partner
        get "success", controller: :suppliers, action: :delivery_partner_success, as: :new_delivery_partner_success
      end

      post "/supplier-details", controller: :suppliers, action: :new_supplier_details
    end

    scope "lead_providers/:lead_provider" do
      resources :lead_provider_users, path: "/users"
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

  root to: "pages#home"
end
