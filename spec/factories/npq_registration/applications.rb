# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_application, class: NPQRegistration::Application do
    user { create(:npq_reg_user) }
    course { create(:npq_reg_course) }
    lead_provider { create(:npq_reg_lead_provider) }
  end
end
