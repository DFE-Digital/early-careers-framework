# frozen_string_literal: true

class DeclarationState < ApplicationRecord
  belongs_to :participant_declaration

  include PGEnum(state_reason: %w[duplicate])

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
    ineligible: "ineligible",
  }

  states.except(:ineligible).each_key do |key|
    bang_method = "#{key}!"
    define_singleton_method(bang_method) do |participant_declaration|
      create!(participant_declaration: participant_declaration, state: key)
      participant_declaration.send(bang_method)
    end
  end

  def self.ineligible!(participant_declaration, reason:)
    participant_declaration.declaration_states
      .create!(state: states[:ineligible], state_reason: reason)
  end
end
