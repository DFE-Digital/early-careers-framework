# frozen_string_literal: true

FactoryBot.define do
  factory :declaration_state do
    participant_declaration
    state { "submitted" }
  end
end
