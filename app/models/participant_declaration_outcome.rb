# frozen_string_literal: true

class ParticipantDeclarationOutcome < ApplicationRecord
  VALID_STATES = %i[passed failed voided].freeze
  private_constant :VALID_STATES

  belongs_to :participant_declaration
  enum state: VALID_STATES.index_with(&:to_s)

  validates :state, presence: true
  validates :completion_date, presence: true
end
