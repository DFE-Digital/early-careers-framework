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
    resources :lead_providers, only: %i[index edit update create new]

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
