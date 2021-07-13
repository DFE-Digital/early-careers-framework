# frozen_string_literal: true

FactoryBot.define do
  factory :npq_validation_data do
    user
    npq_course
    npq_lead_provider

    headteacher_status { NPQValidationData.headteacher_statuses.keys.sample }
    funding_choice { NPQValidationData.funding_choices.keys.sample }
  end
end
