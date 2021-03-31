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
  end

  namespace :demo do
    resources :school_search, only: %i[index]
  end

  resources :nominations, only: %i[index]

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

  resources :nominations, only: [] do
    collection do
      get "choose-location", action: :choose_location
      post "choose-location", action: :receive_location
      get "choose-school", action: :choose_school
      post "choose-school", action: :receive_school
      get "review", action: :review
      post "review", action: :create
      get "success", action: :success
      get "not-eligible", action: :not_eligible
      get "already-renominated", action: :already_renominated
      get "limit-reached", action: :limit_reached
      get "already-associated-with-another_school", action: :already_associated_with_another_school
      get "already-nominated", action: :already_nominated
      get "link-expired", action: :link_expired
      get "link-invalid", action: :link_invalid
      get "nominate-school-lead-success", action: :nominate_school_lead_success
      post "resend-email-after-link-expired", action: :resend_email_after_link_expired
      post "create-school-lead-nomination", action: :create_school_lead_nomination
    end
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
            get "choose-cohorts", action: :choose_cohorts
            post "choose-cohorts", action: :receive_cohorts
            get "review", action: :review_delivery_partner
            post "/", action: :create_delivery_partner
          end
        end
      end
      resources :supplier_users, only: %i[index new create destroy], path: "users" do
        member do
          get "delete", action: :delete
        end
      end
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
        resources :lead_provider_users, only: %i[edit update destroy], path: "users" do
          member do
            get "delete", action: :delete
          end
        end
      end
    end

    scope :administrators, module: "administrators" do
      resources :administrators, only: %i[index new create edit update destroy], path: "/" do
        collection do
          post "new/confirm", action: :confirm, as: :confirm
        end

        member do
          get "delete", action: :delete
        end
      end
    end

    resources :induction_coordinators, only: %i[index edit update], path: "induction-coordinators"
  end

  namespace :schools do
    resource :dashboard, controller: :dashboard, only: :show, path: "/"
    resource :choose_programme, controller: :choose_programme, only: %i[show create], path: "choose-programme"
    resources :cohorts do
      member do
        get "legal"
        get "add_participants"
      end
    end
  end

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  resource :school_search, only: %i[show create], path: "school-search", controller: :school_search

  root "registrations/start#index"
end
