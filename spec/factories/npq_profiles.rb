# frozen_string_literal: true

FactoryBot.define do
  factory :npq_profile do
    user
    npq_course
    npq_lead_provider

    headteacher_status { NPQProfile.headteacher_statuses.keys.sample }
    funding_choice { NPQProfile.funding_choices.keys.sample }
  end
end
