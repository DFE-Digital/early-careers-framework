# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_gdpr_request, class: "GDPRRequest") do
    reason { :restrict_processing }

    trait(:with_cpd_lead_provider) { association :cpd_lead_provider, factory: :seed_cpd_lead_provider }
    trait(:with_teacher_profile) { association :teacher_profile, factory: %i[seed_teacher_profile with_user] }

    trait(:valid) do
      with_cpd_lead_provider
      with_teacher_profile
    end

    after(:build) { |request| Rails.logger.debug("seeded GDPR request to #{request.reason}") }
  end
end
