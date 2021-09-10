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
  get "/induction-tutor-materials/:provider/:year", to: "pages#induction_tutor_materials", as: :induction_tutor_materials
  get "check" => "application#check"
  get "healthcheck" => "healthcheck#check"

  unless Rails.env.production?
    get "/sandbox", to: "sandbox#show"
  end

  if Rails.env.sandbox?
    root to: redirect("/sandbox", status: 307)
  else
    root "start#index"
  end

  get "/check-account", to: "check_account#show"

  resource :csp_reports, only: %i[create]

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
      resources :participants, only: %i[index] do
        member do
          put :defer
          put :withdraw
          put :change_schedule, path: "change-schedule"
        end
      end
      resources :participant_declarations, only: %i[create index], path: "participant-declarations"
      resources :users, only: %i[index create]
      resources :ecf_users, only: %i[index create], path: "ecf-users"
      resources :dqt_records, only: :show, path: "dqt-records"
      resources :participant_validation, only: :show, path: "participant-validation"
      resources :npq_applications, only: :index, path: "npq-applications" do
        member do
          post :accept
          post :reject
        end
      end

      resources :npq_profiles, only: [:create], path: "npq-profiles"

      namespace :data_studio, path: "data-studio" do
        get "/school-rollout", to: "school_rollout#index"
      end
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
        get "not-eligible", action: :not_eligible
        get "limit-reached", action: :limit_reached
        get "already-nominated", action: :already_nominated
      end
    end

    get "/choose-how-to-continue", to: "choose_how_to_continue#new"
    post "/choose-how-to-continue", to: "choose_how_to_continue#create"
    get "/choice-saved", to: "choose_how_to_continue#choice_saved"

    resource :nominate_induction_coordinator, controller: :nominate_induction_coordinator, only: %i[new create], path: "/" do
      collection do
        # start method is redirected to Nominations::ChooseHowToContinueController#new
        # because URL was given in email to schools, so entry point here is now start_nomination
        get "start", to: redirect(path: "/nominations/choose-how-to-continue")
        get "start-nomination", action: :start_nomination
        get "email-used", action: :email_used
        get "name-different", action: :name_different
        get "link-expired", action: :link_expired
        post "link-expired", action: :resend_email_after_link_expired
        get "link-invalid", action: :link_invalid
        get "nominate-school-lead-success", action: :nominate_school_lead_success
      end
    end
  end

  namespace :lead_providers, path: "lead-providers" do
    get "/", to: "content#index", as: :landing_page
    get "/partnership-guide", to: "content#partnership_guide", as: :partnership_guide

    get "/guidance/home" => "guidance#index", as: :guidance_home
    get "/guidance/ecf-usage" => "guidance#ecf_usage", as: :guidance_ecf_usage
    get "/guidance/npq-usage" => "guidance#npq_usage", as: :guidance_npq_usage
    get "/guidance/reference" => "guidance#reference", as: :guidance_reference
    get "/api-docs/v1/api_spec.yml" => "openapi#api_docs", as: :api_docs
    get "/guidance/release-notes" => "guidance#release_notes", as: :guidance_release_notes
    get "/guidance/help" => "guidance#help", as: :guidance_help

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
      resources :cohorts, controller: "schools/cohorts", only: :index do
        member do
          resource :change_programme, only: %i[show update], path: "change-programme", controller: "schools/cohorts/change_programme" do
            post :confirm
          end
          resource :challenge_partnership, only: %i[new create], path: "challenge-partnership", controller: "schools/cohorts/challenge_partnership" do
            post :confirm
          end
          resource :change_training_materials, only: %i[show update], path: "change-training-materials", controller: "schools/cohorts/change_training_materials" do
            post :confirm
          end
        end
      end
      resources :participants, controller: "schools/participants", only: :index
    end

    resources :participants, only: %i[show index destroy] do
      member do
        get :remove

        scope path: "validations", controller: "participants/validations" do
          get ":step", action: :show, as: :validation_step
          post ":step", action: :update
        end
      end
    end
    resource :impersonate, only: %i[create destroy]

    namespace :gias do
      resources :home, only: :index, path: "/"
      resources :school_changes, only: %i[index show], path: "school-changes"
      resources :schools_to_add, only: %i[index show], path: "schools-to-add"
      resources :schools_to_close, only: %i[index show], path: "schools-to-close"
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

  namespace :finance do
    resources :lead_providers, only: %i[index show], path: "lead-providers"
  end

  namespace :participants do
    resource :no_access, only: :show, controller: "no_access"
    resource :start_registrations, path: "/start-registration", only: :show

    scope :validation, as: :validation do
      get "/", to: "validations#start", as: :start
      get "/do-you-want-to-add-your-mentor-information", to: "validations#do_you_want_to_add_mentor_information", as: :do_you_want_to_add_mentor_information
      put "/do-you-want-to-add-your-mentor-information", to: "validations#do_you_want_to_add_mentor_information"
      get "/do-you-know-your-teacher-reference-number", to: "validations#do_you_know_your_trn", as: :do_you_know_your_trn
      put "/do-you-know-your-teacher-reference-number", to: "validations#do_you_know_your_trn"
      get "/have-you-changed-your-name", to: "validations#have_you_changed_your_name", as: :have_you_changed_your_name
      put "/have-you-changed-your-name", to: "validations#have_you_changed_your_name"
      get "/confirm-name-change", to: "validations#confirm_updated_record", as: :confirm_updated_record
      put "/confirm-name-change", to: "validations#confirm_updated_record"
      get "/name-not-updated", to: "validations#name_not_updated", as: :name_not_updated
      put "/name-not-updated", to: "validations#name_not_updated"
      get "/tell-us-your-details", to: "validations#tell_us_your_details", as: :tell_us_your_details
      put "/tell-us-your-details", to: "validations#tell_us_your_details"
      get "/confirm-these-details", to: "validations#confirm_details", as: :confirm_details
      put "/confirm-these-details", to: "validations#confirm_details"
      get "/find-your-teacher-reference-number", to: "validations#find_your_trn", as: :find_your_trn
      get "/get-a-teacher-reference-number", to: "validations#get_a_trn", as: :get_a_trn
      get "/change-your-details-with-the-teacher-regulation-agency", to: "validations#change_your_details_with_tra", as: :change_your_details_with_tra
      get "/check-with-the-teacher-regulation-agency", to: "validations#check_with_tra", as: :check_with_tra
      get "/cannot-find-your-details", to: "validations#cannot_find_details", as: :cannot_find_details
      put "/cannot-find-your-details", to: "validations#cannot_find_details"
      get "/complete", to: "validations#complete", as: :complete
    end
  end

  namespace :schools do
    resources :dashboard, controller: :dashboard, only: %i[index show], path: "/", param: :school_id

    scope "/:school_id" do
      resource :choose_programme, controller: :choose_programme, only: %i[show create], path: "choose-programme" do
        get :confirm_programme, path: "confirm-programme"
        get :choice_saved_design_our_own, path: "design-your-programme"
        get :choice_saved_school_funded_fip, path: "school-funded-fip"
        get :choice_saved_no_early_career_teachers, path: "no-early-career-teachers"
        post :save_programme, path: "save-programme"
        get :success
      end

      resource :year_2020, path: "year-2020", controller: "year2020", only: [], constraints: ->(_request) { FeatureFlag.active?(:year_2020_data_entry) } do
        get "support-materials-for-NQTs", action: :start, as: :start

        get "choose-core-induction-programme", action: :select_cip
        put "choose-core-induction-programme", action: :choose_cip
        get "add-teacher", action: :new_teacher
        put "add-teacher", action: :create_teacher
        get "remove-teacher", action: :remove_teacher
        put "remove-teacher", action: :delete_teacher
        get "edit-teacher", action: :edit_teacher
        put "edit-teacher", action: :update_teacher
        get "check-your-answers", action: :check
        post "check-your-answers", action: :confirm
        get "success", action: :success

        get "no-accredited-materials", action: :no_accredited_materials
      end

      resources :cohorts, only: :show, param: :cohort_id do
        member do
          resources :partnerships, only: :index
          resource :programme, only: %i[edit], controller: "choose_programme"

          resources :participants, only: %i[index show destroy] do
            get :remove
            get :edit_name, path: "edit-name"
            put :update_name, path: "update-name"
            get :edit_email, path: "edit-email"
            put :update_email, path: "update-email"
            get :email_used, path: "email-used"
            get :edit_mentor, path: "edit-mentor"
            put :update_mentor, path: "update-mentor"

            collection do
              multistep_form :add, Schools::AddParticipantForm, controller: :add_participants
            end
          end

          namespace :core_programme, path: "core-programme" do
            resource :materials, only: %i[edit update show] do
              get :info
              get :success
            end
          end

          get "programme-choice", as: :programme_choice
          get "add-participants", as: :add_participants
        end
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

  get "/ministerial-letter", to: redirect("ECF%20Letter.pdf")
  get "/ecf-leaflet", to: redirect("ECFleaflet2021.pdf")

  get "/how-to-set-up-your-programme", to: "step_by_step#show", as: :step_by_step

  post "__session", to: "support/request_spec/session_helper#update" if Rails.env.test?
end
