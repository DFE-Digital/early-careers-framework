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

  scope :participant_outcome_of_user, ->(user_id) { where(participant_declaration_id: ParticipantDeclaration.where(user_id: user_id))&.order("completion_date desc")&.limit(1) }

  class << self
    def latest
      order(created_at: :desc).first
    end

    def to_send_to_qualified_teachers_api
      eligible_outcomes = not_sent_to_qualified_teachers_api
        .where(id: latest_per_declaration.map(&:id))

      eligible_outcomes.passed
        .or(
          eligible_outcomes
            .not_passed
            .where(participant_declaration_id: declarations_where_outcome_passed_and_sent),
        )
    end

    def latest_per_declaration
      select("DISTINCT ON(participant_declaration_id) *")
        .order(:participant_declaration_id, created_at: :desc)
    end

    def declarations_where_outcome_passed_and_sent
      latest_per_declaration
        .passed
        .sent_to_qualified_teachers_api
        .map(&:participant_declaration_id)
    end

    def sent_to_qualified_teachers_api
      where.not(sent_to_qualified_teachers_api_at: nil)
    end

    def not_sent_to_qualified_teachers_api
      where(sent_to_qualified_teachers_api_at: nil)
    end

    def passed
      where(state: :passed)
    end

    def not_passed
      where.not(state: :passed)
    end
  end

  def has_passed?
    return nil if voided?

    passed?
  end

private

  def push_outcome_to_big_query
    ParticipantOutcomes::StreamBigQueryJob.perform_later(participant_outcome_id: id)
  end
end
