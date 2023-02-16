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

  def self.to_send_to_qualified_teachers_api
    latest_outcome = latest
    return latest_outcome if (latest_outcome.has_passed? && !latest_outcome.sent_to_qualified_teachers_api?) || (!latest_outcome.has_passed? && !latest_outcome.sent_to_qualified_teachers_api? && latest_outcome.previous_outcome.has_passed? && latest_outcome.previous_outcome.sent_to_qualified_teachers_api?)
  end

  def has_passed?
    return nil if voided?

    passed?
  end

  def sent_to_qualified_teachers_api?
    !sent_to_qualified_teachers_api_at.nil?
  end

  def previous_outcome
    @previous_outcome ||= self.class.where.not(id:).where(participant_declaration:).where("created_at < ?", created_at).latest
  end

private

  def push_outcome_to_big_query
    ParticipantOutcomes::StreamBigQueryJob.perform_later(participant_outcome_id: id)
  end
end
