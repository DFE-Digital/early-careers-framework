# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :registrations, controllers: {
    sessions: "users/sessions",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"

    namespace :induction_coordinators do
      namespace :registrations do
        get "confirm_school", to: "/users/induction_coordinator_registrations#confirm_school"
        get "check_email", to: "/users/induction_coordinator_registrations#start_registration"
        post "check_email", to: "/users/induction_coordinator_registrations#check_email"
        get "register", to: "/users/induction_coordinator_registrations#new"
        post "register", to: "/users/induction_coordinator_registrations#create"
      end
    end
  end

  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  if Rails.env.development? || Rails.env.deployed_development?
    get "/govspeak_test", to: "govspeak_test#show"
    post "/govspeak_test", to: "govspeak_test#preview"
  end

  root to: "pages#home"
end
