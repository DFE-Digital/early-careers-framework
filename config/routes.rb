# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: :registrations, controllers: {
    sessions: "users/sessions",
    confirmations: "users/confirmations",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
  end

  get "/pages/:page", to: "pages#show"
  get "check" => "application#check"

  resource :cookies, only: %i[show update]
  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :school_invites, only: %i[show create]

  namespace :api do
    resources :school_search, only: %i[index]
  end

  scope path: "induction-programme", module: :induction_programme do
    resource :estimates, only: %i[show create]
    resource :choices, only: %i[show create]
  end

  namespace :demo do
    resources :school_search, only: %i[index]
  end

  namespace :registrations do
    root to: "start#index"
    resource :account_not_found, only: :show, controller: :account_not_found, path: "/account-not-found"
    resource :question_one, only: %i[show create], controller: :question_one, path: "/question-one"
    resource :question_two, only: %i[show create], controller: :question_two, path: "/question-two"
    resource :no_decision, only: :show, controller: :no_decision, path: "/no-decision"
    resource :learn_options, only: :show, controller: :learn_options, path: "/learn-options"
    resource :no_participants, only: :show, controller: :no_participants, path: "/no-participants"
    resource :school_profile, only: %i[show create], controller: :school_profile, path: "/school-profile"
    resource :user_profile, only: %i[new create], controller: :user_profile, path: "/user-profile"
    resource :verification_sent, only: :show, controller: :verification_sent, path: "/verification-sent"
    resource :school_not_eligible, only: :show, controller: :school_not_eligible, path: "/school-not-eligible"
    resource :school_registered, only: :show, controller: :school_registered, path: "/school-registered"
    resource :school_not_confirmed, only: :show, controller: :school_not_confirmed, path: "/school-not-confirmed"
  end

  namespace :lead_providers do
    resources :your_schools, only: %i[index create]
    resources :school_details, only: %i[show]
  end

  namespace :admin do
    scope :suppliers, module: "suppliers" do
      resources :suppliers, only: :index, path: "/"
      scope "new" do
        resources :delivery_partners, only: [], path: "delivery-partner" do
          collection do
            get "choose-name", action: :choose_name
            post "choose-name", action: :receive_name
            get "choose-lps", action: :choose_lead_providers
            post "choose-lps", action: :receive_lead_providers
            get "review", action: :review_delivery_partner
            post "/", action: :create_delivery_partner
          end
        end
      end
      resources :supplier_users, only: %i[index new create], path: "users"
      scope "users/new" do
        post "/", controller: :supplier_users, action: :receive_supplier
        get "user-details", controller: :supplier_users, action: :user_details, as: :new_supplier_user_details
        post "user-details", controller: :supplier_users, action: :receive_user_details
        get "review", controller: :supplier_users, action: :review, as: :new_supplier_user_review
      end

      resources :delivery_partners, only: %i[edit update destroy], path: "delivery-partners" do
        member do
          get "delete", action: :delete
        end
      end

      scope path: "lead-providers" do
        resources :lead_provider_users, only: %i[edit update], path: "users"
      end
    end
    scope :profiles, module: "profiles" do
      root to: redirect("/admin/profiles/admin_profiles")
      resources :admin_profiles, only: %i[index show destroy]
      resources :induction_coordinator_profiles, only: %i[index show destroy]
      resources :lead_provider_profiles, only: %i[index show destroy]
    end

    scope :administrators, module: "administrators" do
      resources :administrators, only: %i[index new create edit update], path: "/" do
        collection do
          post "new/confirm", action: :confirm, as: :confirm
        end
      end
    end

    resources :induction_coordinators, only: %i[index edit update], path: "induction-coordinators"
  end

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  resource :school_search, only: %i[show create], path: "school-search", controller: :school_search

  root "registrations/start#index"
end
