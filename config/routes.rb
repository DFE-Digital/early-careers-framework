# frozen_string_literal: true

Rails.application.routes.draw do
  mount_sidekiq = -> { mount Sidekiq::Web => "/sidekiq" }
  authenticate(:user, :admin?.to_proc, &mount_sidekiq)

  devise_for :users, skip: %i[registrations confirmations], controllers: {
    sessions: "users/sessions",
  }

  devise_scope :user do
    get "/users/confirm_sign_in", to: "users/sessions#redirect_from_magic_link"
    post "/users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
    get "/users/signed-out", to: "users/sessions#signed_out"
    get "/users/link-invalid", to: "users/sessions#link_invalid"
  end

  direct :feedback_form do
    "https://docs.google.com/forms/d/e/1FAIpQLSdjpB1VMwZlcQxOoTzfW_bw7mnnKbGHek24_uZRhIRDid9f-Q/viewform?usp=sf_link"
  end

  scope :pages, controller: "pages" do
    get "/ect-additional-information", to: redirect("https://www.gov.uk/guidance/guidance-for-early-career-teachers-ects-ecf-based-training")
    get "/mentor-additional-information", to: redirect("https://www.gov.uk/guidance/guidance-for-mentors-how-to-support-ecf-based-training")
    get "/school-leader-additional-information", to: redirect("https://www.gov.uk/guidance/guidance-for-schools-how-to-manage-ecf-based-training")

    get "/:page", action: :show, as: :page
  end

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
    resource :notify_callback, only: :create, path: "notify-callback"

    concern :participant_actions do
      put :withdraw, on: :member
      put :defer, on: :member
      put :resume, on: :member
      put :change_schedule, path: "change-schedule", on: :member
    end

    namespace :v1 do
      resources :npq_funding, only: [:show], path: "npq-funding", param: :trn

      resources :ecf_participants, path: "participants/ecf", only: %i[index show] do
        concerns :participant_actions
      end
      resources :participants, only: %i[index], controller: "ecf_participants"
      resources :participants, only: [] do
        concerns :participant_actions
        member { put :resume }
      end
      resources :participant_declarations, only: %i[create index show], path: "participant-declarations" do
        member { put :void }
      end
      resources :npq_participants, only: %i[index show], path: "participants/npq" do
        concerns :participant_actions
        collection do
          resources :outcomes, only: %i[index], controller: "provider_outcomes"
          get ":participant_id/outcomes", to: "participant_outcomes#index"
          post ":participant_id/outcomes", to: "participant_outcomes#create"
        end
      end
      resources :users, only: %i[index create]
      resources :ecf_users, only: %i[index create], path: "ecf-users"
      resources :participant_validation, only: %i[create], path: "participant-validation"
      resources :npq_applications, only: %i[index show], path: "npq-applications" do
        member do
          post :accept
          post :reject
        end
      end

      resources :npq_profiles, only: %i[show create update], path: "npq-profiles"

      namespace :data_studio, path: "data-studio" do
        get "/school-rollout", to: "school_rollout#index"
      end

      namespace :npq do
        resources :users, only: %i[show create update]
        resource :previous_funding, only: [:show]
      end
    end

    namespace :v2 do
      resources :ecf_participants, path: "participants/ecf", only: %i[index show] do
        concerns :participant_actions
      end
      resources :participants, only: %i[index], controller: "ecf_participants"
      resources :participants, only: [] do
        concerns :participant_actions
        member { put :resume }
      end
      resources :participant_declarations, only: %i[create index show], path: "participant-declarations" do
        member { put :void }
      end
      resources :npq_participants, only: %i[index show], path: "participants/npq" do
        concerns :participant_actions
        collection do
          resources :outcomes, only: %i[index], controller: "provider_outcomes"
          get ":participant_id/outcomes", to: "participant_outcomes#index"
          post ":participant_id/outcomes", to: "participant_outcomes#create", as: :create_outcome
        end
      end
      resources :npq_enrolments, only: %i[index], path: "npq-enrolments"
      resources :users, only: %i[index create]
      resources :ecf_users, only: %i[index create], path: "ecf-users"
      resources :participant_validation, only: %i[create], path: "participant-validation"
      resources :npq_applications, only: %i[index show], path: "npq-applications" do
        member do
          post :accept
          post :reject
        end
      end

      resources :npq_profiles, only: %i[show create update], path: "npq-profiles"

      namespace :data_studio, path: "data-studio" do
        get "/school-rollout", to: "school_rollout#index"
      end
    end

    namespace :v3, constraints: ->(_request) { FeatureFlag.active?(:api_v3) } do
      resources :statements, only: %i[index show], controller: "finance/statements"
      resources :delivery_partners, only: %i[index show], path: "delivery-partners"
      resources :partnerships, path: "partnerships/ecf", only: %i[show index create update], controller: "ecf/partnerships"
      resources :npq_participants, only: %i[index show], path: "participants/npq" do
        concerns :participant_actions
        collection do
          resources :outcomes, only: %i[index], controller: "provider_outcomes"
          get ":participant_id/outcomes", to: "participant_outcomes#index"
          post ":participant_id/outcomes", to: "participant_outcomes#create"
        end
      end
      resources :ecf_schools, path: "schools/ecf", only: %i[index show], controller: "ecf/schools"
    end
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

    resource :nominate_induction_coordinator, controller: :nominate_induction_coordinator, only: [], path: "/" do
      collection do
        # start method is redirected to Nominations::ChooseHowToContinueController#new
        # because URL was given in email to schools, so entry point here is now start_nomination
        get "start", to: redirect(path: "/nominations/choose-how-to-continue")
        get "start-nomination", action: :start_nomination
        get "full-name", action: :full_name
        put "full-name", action: :check_name
        get "email", action: :email
        put "email", action: :check_email
        get "check-details", action: :check
        post "check-details", action: :create
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

    # Keeping the urls to old guidance urls, but they need to lead to new api-reference ones
    get "/guidance/home", to: redirect("/api-reference")
    get "/guidance/ecf-usage", to: redirect("/api-reference/ecf-usage")
    get "/guidance/npq-usage", to: redirect("/api-reference/npq-usage")
    get "/guidance/reference", to: redirect("/api-reference/reference")
    get "/guidance/release-notes", to: redirect("/api-reference/release-notes")
    get "/guidance/help", to: redirect("/api-reference/help")

    get "/api-docs/v1/api_spec.yml" => "openapi#api_docs", as: :api_docs

    resources :your_schools, path: "/your-schools", only: %i[index create]
    resources :partnerships, only: %i[show] do
      collection do
        get :active
      end
    end

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

  get "admin", to: "admin/home#show"
  namespace :admin do
    resource :home, only: :show, controller: "home"
    resources :schools, only: %i[index show] do
      resources :induction_coordinators, controller: "schools/induction_coordinators", only: %i[new create edit update], path: "induction-coordinators"
      get "/replace-or-update-induction-tutor", to: "schools/replace_or_update_induction_tutor#show"
      post "/replace-or-update-induction-tutor", to: "schools/replace_or_update_induction_tutor#choose"
      resources :cohorts, controller: "schools/cohorts", only: :index do
        member do
          resource :change_programme, only: %i[show update], path: "change-programme", controller: "schools/cohorts/change_programme" do
            post :confirm
          end
          resource :change_training_materials, only: %i[show update], path: "change-training-materials", controller: "schools/cohorts/change_training_materials" do
            post :confirm
          end
        end
      end
      resources :partnerships, only: [] do
        resource :challenge_partnership, only: %i[new create], path: "challenge-partnership", controller: "schools/cohorts/challenge_partnership" do
          post :confirm
        end
      end
      resources :participants, controller: "schools/participants", only: :index
    end

    resources :participants, only: %i[index destroy] do
      get "/", to: redirect("/admin/participants/%{participant_id}/details")
      resource :details, only: :show, controller: "participants/details"
      resource :school, only: :show, controller: "participants/school"
      resource :history, only: :show, controller: "participants/history"
      resource :induction_records, only: :show, controller: "participants/induction_records"
      resource :cohorts, only: :show, controller: "participants/cohorts"
      resource :declaration_history, only: :show, controller: "participants/declaration_history"
      resource :identities, only: :show, controller: "participants/identities"
      resource :event_history, only: :show, controller: "participants/event_history"

      resource :validation_data, path: "validation-data", only: :show, controller: "participants/validation_data" do
        member do
          get "full-name", action: :full_name, as: :full_name
          put "full-name", action: :full_name
          get "teacher-reference-number", action: :trn, as: :trn
          put "teacher-reference-number", action: :trn
          get "date-of-birth", action: :date_of_birth, as: :date_of_birth
          put "date-of-birth", action: :date_of_birth
          get "national-insurance-number", action: :nino, as: :nino
          put "national-insurance-number", action: :nino
          post "validate-details", action: :validate_details, as: :validate_details
        end
      end

      member do
        put :update_email, path: "update-email"
        get :remove
        scope path: "validations", controller: "participants/validations" do
          get ":step", action: :show, as: :validation_step
          post ":step", action: :update
        end
      end

      resource :change_cohort, only: %i[edit update], controller: "participants/change_cohort"
      resource :change_name, only: %i[edit update], controller: "participants/change_name", path: "name"
      resource :change_email, only: %i[edit update], controller: "participants/change_email", path: "email"

      resource :add_to_school_mentor_pool, only: %i[new create], controller: "participants/add_to_school_mentor_pool"

      resource :npq_change_full_name, only: %i[edit update], controller: "participants/npq/change_full_name"
      resource :npq_change_email, only: %i[edit update], controller: "participants/npq/change_email"

      resource :change_induction_start_date, only: %i[edit update], controller: "participants/change_induction_start_date"

      resource :school_transfer, path: "school-transfer", only: [], controller: "participants/school_transfer" do
        member do
          get "select-school", action: :select_school, as: :select_school
          put "select-school", action: :select_school
          get "transfer-options", action: :transfer_options, as: :transfer_options
          put "transfer-options", action: :transfer_options
          get "start-date", action: :start_date, as: :start_date
          put "start-date", action: :start_date
          get "email", action: :email, as: :email
          put "email", action: :email
          get "check-answers", action: :check_answers, as: :check_answers
          put "check-answers", action: :check_answers
          get "cannot-transfer", action: :cannot_transfer, as: :cannot_transfer
        end
      end
    end

    resources :notes, only: %i[edit update]
    resource :impersonate, only: %i[create destroy]

    namespace :gias do
      resources :home, only: :index, path: "/"
      resources :schools, only: :show, path: "schools"
      resources :school_changes, only: %i[index show], path: "school-changes"
      resources :schools_to_add, only: %i[index], path: "schools-to-add"
      resources :schools_to_close, only: %i[index], path: "schools-to-close"
      resources :major_school_changes, only: %i[index], path: "major-school-changes"
    end

    unless Rails.env.production?
      namespace :test_data, path: "test-data" do
        get "/", to: redirect("/admin/test-data/fip-schools")
        resources :fip_schools, only: :index, path: "fip-schools"
        resources :cip_schools, only: :index, path: "cip-schools"
        resources :yet_to_choose_schools, only: :index, path: "yet-to-choose-schools"
        resources :unclaimed_schools, only: :index, path: "unclaimed-schools" do
          member do
            get "generate-link", action: :generate_link
          end
        end
      end
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

    namespace :delivery_partners, path: "delivery-partners" do
      resources :users, only: %i[index new create edit update destroy] do
        member do
          get "delete", action: :delete
        end
      end
    end

    namespace :appropriate_bodies, path: "appropriate-bodies" do
      resources :users, only: %i[index new create edit update destroy] do
        member do
          get "delete", action: :delete
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

    namespace :npq do
      resource :applications, only: [] do
        resources :exports, only: %i[index new create], controller: "applications/exports"
        get "/eligibility_imports/example", to: "applications/eligibility_imports#example", as: :example_csv_file
        resources :eligibility_imports, only: %i[index new create show], controller: "applications/eligibility_imports"

        get "/analysis", to: "applications/analysis#invalid_payments_analysis", as: :analysis
        resources :applications, only: %i[index show]
        resources :edge_cases, controller: "applications/edge_cases", only: %i[index show]
        resources :eligible_for_funding, controller: "applications/eligible_for_funding", only: %i[edit update]
        resources :eligibility_status, controller: "applications/eligibility_status", only: %i[edit update]
        resources :notes, controller: "applications/notes", only: %i[edit update]
      end
    end
  end

  namespace :finance do
    namespace :ecf do
      resources :duplicates, only: %i[index show destroy edit], path_names: { edit: "delete" } do
        resources :compare, module: "duplicates", only: %i[show]
      end
    end

    resource :landing_page, only: :show, path: "manage-cpd-contracts", controller: "landing_page"
    resources :participants, only: %i[index show]
    resources :participant_profiles, only: [] do
      namespace :ecf do
        resource :induction_records, only: [] do
          collection do
            get ":induction_record_id/change_training_status/new", to: "change_training_statuses#new", as: :new
            post ":induction_record_id/change_training_status", to: "change_training_statuses#create", as: :create
          end
        end
      end
      namespace :npq do
        resource :change_training_status, only: %i[new create]
        resource :change_lead_provider, only: %i[new create update]
      end
    end
    resources :npq_applications, only: [] do
      resource :change_lead_provider_approval_status, only: %i[new create]
    end

    namespace :banding_tracker, path: "banding-tracker" do
      resources :providers, only: %i[show]
      resource :provider_choice, only: %i[new create], path: "choose-provider", path_names: { new: "" }
    end

    resource :payment_breakdowns, only: :show, path: "payment-breakdowns", controller: "payment_breakdowns" do
      get "/choose-programme", to: "payment_breakdowns#select_programme", as: :select_programme
      post "/choose-programme", to: "payment_breakdowns#choose_programme", as: :choose_programme
      get "/choose-provider-ecf", to: "payment_breakdowns#select_provider_ecf", as: :select_provider_ecf
      post "/choose-provider-ecf", to: "payment_breakdowns#choose_provider_ecf", as: :choose_provider_ecf
      get "/choose-provider-npq", to: "payment_breakdowns#select_provider_npq", as: :select_provider_npq
      post "/choose-provider-npq", to: "payment_breakdowns#choose_provider_npq", as: :choose_provider_npq

      collection do
        post :choose_npq_statement, path: "choose-npq-statement"
        post :choose_ecf_statement, path: "choose-ecf-statement"
      end
    end

    resources :schedules, only: %i[index show]

    namespace :ecf do
      resources :statements, only: [] do
        resource :assurance_report, path: "assurance-report", only: :show, format: :csv
      end

      resources :payment_breakdowns, only: [] do
        resources :statements, only: %i[show] do
          resource :voided, controller: "participant_declarations/voided", path: "voided", only: %i[show]
        end
      end
    end

    namespace :npq do
      resources :statements, only: [] do
        resource :assurance_report, path: "assurance-report", only: :show, format: :csv
      end

      resources :lead_providers, path: "payment-overviews", controller: "payment_overviews", only: %i[show] do
        resources :statements, only: %i[show] do
          resources :courses, only: %i[show], controller: "course_payment_breakdowns"
          resource :voided, controller: "participant_declarations/voided", path: "voided", only: %i[show]
        end
      end

      resources :contracts, only: %i[show]
    end
  end

  get "/finance", to: redirect("/finance/manage-cpd-contracts")

  namespace :participants do
    resource :no_access, only: :show, controller: "no_access"
    resource :start_registrations, path: "/start-registration", only: :show do
      get "get-a-trn", action: :get_a_trn
    end

    multistep_form :validation, Participants::ParticipantValidationForm, controller: :validations do
      get :no_trn, as: nil
      get :already_completed, as: nil
    end
  end

  namespace :schools do
    resources :dashboard, controller: :dashboard, only: %i[index show], path: "/", param: :school_id

    scope "/:school_id" do
      resources :participants, only: %i[index show destroy] do
        get :remove
        get :edit_name, path: "edit-name"
        put :update_name, path: "update-name"
        get :edit_email, path: "edit-email"
        put :update_email, path: "update-email"
        get :email_used, path: "email-used"
        get :edit_mentor, path: "edit-mentor"
        put :update_mentor, path: "update-mentor"
        get :add_appropriate_body, path: "add-appropriate-body"
        get :appropriate_body_confirmation, path: "appropriate-body-confirmation"
        appropriate_body_selection_routes :participants

        resource :transfer_out, path: "transfer-out", only: [] do
          collection do
            get "is-teacher-transferring", to: "transfer_out#check_transfer", as: :check_transfer
            get "teacher-end-date", to: "transfer_out#teacher_end_date"
            put "teacher-end-date", to: "transfer_out#teacher_end_date"
            get "check-answers", to: "transfer_out#check_answers"
            put "check-answers", to: "transfer_out#check_answers"
            get "complete", to: "transfer_out#complete"
          end
        end
      end

      resources :cohorts, only: :show, param: :cohort_id do
        member do
          get "programme-choice", as: :programme_choice
          get "change-programme", as: :change_programme
          get "roles", as: :roles

          scope module: :cohorts, path: "appropriate-body" do
            get "add", to: "appropriate_body#add", as: :add_appropriate_body
            get "change", to: "appropriate_body#change", as: :change_appropriate_body
            appropriate_body_selection_routes "appropriate_body"
            get "confirm", to: "appropriate_body#confirm"
          end

          resources :partnerships, only: :index
          resource :programme, only: %i[edit], controller: "choose_programme"

          resource :setup_school_cohort, path: "register-programme" do
            get "does-your-school-expect-any-ects", to: "setup_school_cohort#expect_any_ects", as: :expect_any_ects
            put "does-your-school-expect-any-ects", to: "setup_school_cohort#expect_any_ects"

            get "no-expected-ects", to: "setup_school_cohort#no_expected_ects"
            get "how-will-you-run-training", to: "setup_school_cohort#how_will_you_run_training"
            put "how-will-you-run-training", to: "setup_school_cohort#how_will_you_run_training"

            get "programme-confirmation", to: "setup_school_cohort#programme_confirmation"
            put "programme-confirmation", to: "setup_school_cohort#programme_confirmation"

            get "training-confirmation", to: "setup_school_cohort#training_confirmation"

            get "change-provider", to: "setup_school_cohort#change_provider"
            put "change-provider", to: "setup_school_cohort#change_provider"

            get "what-changes", to: "setup_school_cohort#what_changes"
            put "what-changes", to: "setup_school_cohort#what_changes"

            get "provider-relation-invalid", to: "setup_school_cohort#provider_relation_invalid"
            put "provider-relation-invalid", to: "setup_school_cohort#provider_relation_invalid"

            get "use-different-delivery-partner", to: "setup_school_cohort#use_different_delivery_partner"
            put "use-different-delivery-partner", to: "setup_school_cohort#use_different_delivery_partner"

            get "what-changes-confirmation", to: "setup_school_cohort#what_changes_confirmation"
            put "what-changes-confirmation", to: "setup_school_cohort#what_changes_confirmation"

            get "what-changes-submitted", to: "setup_school_cohort#what_changes_submitted"

            appropriate_body_selection_routes :setup_school_cohort

            get "complete", to: "setup_school_cohort#complete"
          end

          resources :participants, only: %i[index show destroy] do
            collection do
              scope module: :add_participants do
                wizard_scope :who_to_add, path: "who" do
                  get "/", to: "who_to_add#show", as: :start, step: "participant-type"
                  get "/sit-mentor", to: "who_to_add#show", as: :sit_start, step: "yourself"
                end

                wizard_scope :transfer do
                  get "/", to: "transfer#show", as: :start, step: "joining-date"
                  get "/same-provider", to: "transfer#show", as: :start_same_provider, step: "email"
                end

                wizard_scope :add do
                  get "/", to: "add#show", as: :start, step: "email"
                  get "/sit-mentor", to: "add#show", as: :sit_start, step: "check-answers"
                  appropriate_body_selection_routes :add
                  get :change_appropriate_body, path: "change-appropriate-body", controller: :add
                end
              end
            end
          end

          namespace :core_programme, path: "core-programme" do
            resource :materials, only: %i[edit update show] do
              get :info
              get :success
            end
          end

          resource :choose_programme, controller: :choose_programme, only: %i[show create], path: "choose-programme" do
            get :confirm_programme, path: "confirm-programme"
            post :choose_appropriate_body, path: "choose-appropriate-body"
            get :success

            appropriate_body_selection_routes :choose_programme
          end
        end
      end

      resource :change_sit, only: [], controller: "change_sit", path: "change-sit" do
        get :name
        post :name, action: :set_name
        get :email
        post :email, action: :set_email
        get :check_details, path: "check-details"
        get :confirm
        post :confirm, action: :save
        get :success
      end
    end
  end

  get "/delivery-partners/start", to: "start#delivery_partners", as: :start_delivery_partners
  scope module: "delivery_partners" do
    resources :delivery_partners, path: "delivery-partners", only: %i[index create] do
      resources :participants, only: %i[index]
    end
  end

  get "/appropriate-bodies/start", to: "start#appropriate_bodies", as: :start_appropriate_bodies
  scope module: "appropriate_bodies" do
    resources :appropriate_bodies, path: "appropriate-bodies", only: %i[index create] do
      resources :participants, only: %i[index]
    end
  end

  resource :choose_role, path: "choose-role", only: %i[show create] do
    member do
      get :contact_support
    end
  end

  get "/403", to: "errors#forbidden", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/ministerial-letter", to: redirect("ECF%20Letter.pdf")
  get "/ecf-leaflet", to: redirect("ECFleaflet2021.pdf")

  get "/how-to-set-up-your-programme", to: "step_by_step#show", as: :step_by_step

  get "/assets/govuk/assets/fonts/:name.:extension", to: redirect("/api-reference/assets/govuk/assets/fonts/%{name}.%{extension}")
  get "/assets/govuk/assets/images/:name.:extension", to: redirect("/api-reference/assets/govuk/assets/images/%{name}.%{extension}")

  post "__session", to: "support/request_spec/session_helper#update" if Rails.env.test?
end
