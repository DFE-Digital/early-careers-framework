# frozen_string_literal: true

class ParticipantOutcome::NPQ < ApplicationRecord
  self.table_name = "participant_outcomes"

  VALID_STATES = %i[passed failed voided].freeze
  PERMITTED_STATES = %i[passed failed].freeze
  private_constant :VALID_STATES

  belongs_to :participant_declaration, class_name: "ParticipantDeclaration::NPQ"
  has_many :participant_outcome_api_requests, foreign_key: :participant_outcome_id

  enum state: VALID_STATES.index_with(&:to_s)

  validates :state, presence: true
  validates :completion_date, presence: true, future_date: true

  after_commit :push_outcome_to_big_query

  def self.latest
    order(created_at: :desc).first
  end

  def has_passed?
    return nil if voided?

    passed?
  end

private

  def push_outcome_to_big_query
    NPQ::StreamBigQueryParticipantOutcomeJob.perform_later(participant_outcome_id: id)
  end
end
