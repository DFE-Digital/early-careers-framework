# frozen_string_literal: true

class DeclarationState < ApplicationRecord
  class << self
    %i[submitted eligible voided payable paid].each do |state|
      method_name = "#{state}!"
      define_singleton_method(method_name) do |participant_declaration|
        create!(participant_declaration: participant_declaration, state: state)
        # participant_declaration.send(method_name)
      end
    end
  end

  belongs_to :participant_declaration

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    # awaiting_clawback: "awaiting_clawback",
    # clawed_back: "clawed_back"
    voided: "voided",
  }
end
