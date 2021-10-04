# frozen_string_literal: true

class DeclarationState < ApplicationRecord
  class << self
    def submit!(participant_declaration:)
      create!(participant_declaration: participant_declaration)
    end

    def void!(participant_declaration:)
      create!(participant_declaration: participant_declaration, state: "voided")
    end

    def pay!(participant_declaration:)
      create!(participant_declaration: participant_declaration, state: "paid")
    end
  end

  belongs_to :participant_declaration

  enum state: {
    submitted: "submitted",
    payable: "payable",
    paid: "paid",
    # awaiting_clawback: "awaiting_clawback",
    # clawed_back: "clawed_back"
    voided: "voided",
  }
end
