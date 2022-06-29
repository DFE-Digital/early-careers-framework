# frozen_string_literal: true

class DeclarationState < ApplicationRecord
  belongs_to :participant_declaration

  enum state_reason: {
    duplicate: "duplicate",
  }

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
    ineligible: "ineligible",
    awaiting_clawback: "awaiting_clawback",
    clawed_back: "clawed_back",
  }

  states.each_key do |key|
    bang_method = "#{key}!"
    define_singleton_method(bang_method) do |participant_declaration, **args|
      create!(state: key, participant_declaration:, **args)
      participant_declaration.send(bang_method)
    end
  end
end
