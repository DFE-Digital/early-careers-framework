# frozen_string_literal: true

FactoryBot.define do
  factory :npq_application_eligibility_import, class: NPQApplications::EligibilityImport do
    filename { "#{SecureRandom.uuid}.csv" }
    user { create(:user, :admin) }
    status { :pending }
    import_errors { [] }

    trait :pending do
      status { :pending }
    end

    trait :processing do
      status { :processing }
    end

    trait :completed do
      status { :completed }
      updated_records { 2 }
      processed_at { Time.current }
      import_errors { [] }
    end

    trait :completed_with_errors do
      status { :completed_with_errors }
      updated_records { 1 }
      processed_at { Time.current }
      import_errors { ["ROW 2: Application with ecf_id #{application_id} invalid: Bad Data"] }
    end

    trait :failed do
      status { :failed }
      processed_at { Time.current }
      import_errors { ["Processing Failed, contact an administrator for details"] }
    end
  end
end
