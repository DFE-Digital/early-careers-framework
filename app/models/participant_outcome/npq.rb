# frozen_string_literal: true

class ParticipantOutcome::NPQ < ApplicationRecord
  self.table_name = "participant_outcomes"

  VALID_STATES = %i[passed failed voided].freeze
  PERMITTED_STATES = %i[passed failed].freeze
  private_constant :VALID_STATES

  belongs_to :participant_declaration, class_name: "ParticipantDeclaration::NPQ"
  enum state: VALID_STATES.index_with(&:to_s)

  validates :state, presence: true
  validates :completion_date, presence: true, future_date: true

  def self.latest
    order(created_at: :desc).first
  end
end
