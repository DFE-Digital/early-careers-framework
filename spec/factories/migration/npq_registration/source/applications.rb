# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_source_application, class: Migration::NPQRegistration::Source::Application do
    user { create(:npq_reg_source_user) }
    course { create(:npq_reg_source_course) }
    lead_provider { create(:npq_reg_source_lead_provider) }
    school { create(:npq_reg_source_school) }
    school_urn { school.urn }
  end
end
