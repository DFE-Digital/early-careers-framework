# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations confirmations], controllers: {
    sessions: "users/sessions",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
    get "/users/signed-out", to: "users/sessions#signed_out"
    get "/users/link-invalid", to: "users/sessions#link_invalid"
  end

  get "/pages/:page", to: "pages#show", as: :page
  get "check" => "application#check"

  unless Rails.env.production?
    get "/sandbox", to: "sandbox#show"
  end

  if Rails.env.sandbox?
    root to: redirect("/sandbox", status: 307)
  else
    root "start#index"
  end

  get "/check-account", to: "check_account#show"

  resource :cookies, only: %i[show update]
  resource :privacy_policy, only: %i[show update], path: "privacy-policy"
  resource :accessibility_statement, only: :show, path: "accessibility-statement"
  resource :dashboard, controller: :dashboard, only: :show
  resource :supplier_dashboard, controller: :supplier_dashboard, only: :show
  resource :challenge_partnership, path: "report-incorrect-partnership", only: %i[show create] do
    collection do
      get "link-expired", action: :link_expired
      get "already-challenged", action: :already_challenged
      get "success", action: :success
    end
  end

  namespace :api, defaults: { format: "json" } do
    resources :school_search, only: %i[index]
    resource :notify_callback, only: :create, path: "notify-callback"

    namespace :v1 do
      resources :participant_declarations, only: %i[create], path: "participant-declarations"
      resources :users, only: :index
      resources :dqt_records, only: :show, path: "dqt-records"
    end
  end

  namespace :demo do
    resources :school_search, only: %i[index]
  end

  scope :nominations, module: :nominations do
    resource :request_nomination_invite, controller: :request_nomination_invite, only: [], path: "/" do
      collection do
        get "resend-email", action: :resend_email
        get "choose-location", action: :choose_location
        post "choose-location", action: :receive_location
        get "choose-school", action: :choose_school
        post "choose-school", action: :receive_school
        get "review", action: :review
        post "review", action: :create
        get "success", action: :success
        get "cip-only", action: :cip_only
        get "not-eligible", action: :not_eligible
        get "limit-reached", action: :limit_reached
        get "already-nominated", action: :already_nominated
      end
    end
    resource :nominate_induction_coordinator, controller: :nominate_induction_coordinator, only: %i[new create], path: "/" do
      collection do
        get "start", action: :start
        get "email-used", action: :email_used
        get "link-expired", action: :link_expired
        post "link-expired", action: :resend_email_after_link_expired
        get "link-invalid", action: :link_invalid
        get "nominate-school-lead-success", action: :nominate_school_lead_success
      end
    end
  end

  namespace :lead_providers, path: "lead-providers" do
    resources :your_schools, path: "/your-schools", only: %i[index create]
    resources :partnerships, only: %i[show]

    namespace :report_schools, path: "report-schools" do
      get :start, to: "base#start"
      post "", to: "base#create"
      get :success, to: "base#success"

      resource :delivery_partner, only: %i[show create], path: "delivery-partner"
      resource :csv, only: %i[show create], controller: "csv" do
        get :errors
        post :proceed
      end
      resource :confirm, only: %i[show], controller: :confirm do
        post :remove_school
      end
    end
  end

  namespace :admin do
    resources :schools, only: %i[index show] do
      resources :induction_coordinators, controller: "schools/induction_coordinators", only: %i[new create edit update], path: "induction-coordinators"
      get "/replace-or-update-induction-tutor", to: "schools/replace_or_update_induction_tutor#show"
      post "/replace-or-update-induction-tutor", to: "schools/replace_or_update_induction_tutor#choose"
      resources :cohorts, controller: "schools/cohorts", only: :index
    end

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
    resource :choose_programme, controller: :choose_programme, only: %i[show create], path: "choose-programme" do
      get :advisory

      get :confirm_programme, path: "confirm-programme"
      post :save_programme, path: "save-programme"
      get :success
    end
    resources :cohorts, only: :show do
      resources :partnerships, only: :index
      resource :programme, only: %i[edit], controller: "choose_programme"

      namespace :core_programme, path: "core-programme" do
        resource :materials, only: %i[edit update show] do
          get :info
          get :success
        end
      end

      member do
        get "programme-choice", as: :programme_choice
        get "add-participants", as: :add_participants
      end
    end
  end

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  mount OpenApi::Rswag::Ui::Engine => "/api-docs"
  mount OpenApi::Rswag::Api::Engine => "/api-docs"

  resource :school_search, only: %i[show create], path: "school-search", controller: :school_search

  post "__session", to: "support/request_spec/session_helper#update" if Rails.env.test?
end
