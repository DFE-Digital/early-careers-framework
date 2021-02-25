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

  resource :dashboard, controller: :dashboard, only: :show

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  if Rails.env.development? || Rails.env.deployed_development?
    get "/govspeak_test", to: "govspeak_test#show"
    post "/govspeak_test", to: "govspeak_test#preview"
  end

  resource :core_induction_programme, controller: :core_induction_programme, only: :show, as: "cip", path: "/core-induction-programme" do
    get "download-export", to: "core_induction_programme#download_export", as: "download_export"

    resources :years, controller: "core_induction_programme/years", only: %i[show edit update] do
      resources :modules, controller: "core_induction_programme/modules", only: %i[show edit update] do
        resources :lessons, controller: "core_induction_programme/lessons", only: %i[show edit update] do
          resources :parts, controller: "core_induction_programme/lesson_parts", only: %i[show edit update] do
            get "split", to: "core_induction_programme/lesson_parts#show_split", as: "split"
            post "split", to: "core_induction_programme/lesson_parts#split"
          end
          resource :progress, controller: "core_induction_programme/progress", only: %i[update]
        end
      end
    end
  end

  root to: "core_induction_programme#show"
end
