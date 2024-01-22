# frozen_string_literal: true

FactoryBot.define do
  factory :validation_error do
    form_object { "RefereeInterface::ReferenceFeedbackForm" }
    details { { feedback: { messages: ["Enter feedback"], value: "" } } }
    user factory: %i[user]
    request_path { "/schools" }
  end
end
