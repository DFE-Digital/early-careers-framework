# frozen_string_literal: true

class DeclarationState < ApplicationRecord
  belongs_to :participant_declaration

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
  }

  states.keys.each do |key|
    bang_method = "#{key}!"
    define_singleton_method(bang_method) do |participant_declaration|
        create!(participant_declaration: participant_declaration, state: key)
        participant_declaration.send(bang_method)
      end
  end
end
