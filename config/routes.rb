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

  get "check" => "application#check"

  resource :cookies, only: %i[show update]
  resource :dashboard, controller: :dashboard, only: :show
  resource :username, controller: :username, only: %i[new create edit update]

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  unless Rails.env.production?
    get "/govspeak_test", to: "govspeak_test#show"
    post "/govspeak_test", to: "govspeak_test#preview"
  end

  resources :core_induction_programmes, path: "core-induction-programmes", only: %i[show index], as: "cip" do
    get "create-module", to: "core_induction_programmes/modules#new"
    post "create-module", to: "core_induction_programmes/modules#create"
  end
  get "download-export", to: "core_induction_programmes#download_export", as: :download_export

  scope path: "/", module: :core_induction_programmes do
    resources :years, only: %i[new create edit update]

    resources :modules, only: %i[show edit update]
    resources :lessons, only: %i[show edit update] do
      resource :progress, only: %i[update]
    end

    resources :lesson_parts, only: %i[show edit update destroy] do
      get "split", to: "lesson_parts#show_split", as: "split"
      post "split", to: "lesson_parts#split"
      get "show_delete", to: "lesson_parts#show_delete"
    end
  end
  root to: "start#index"
end
