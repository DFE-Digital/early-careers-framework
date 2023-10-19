# frozen_string_literal: true

module NPQ
  class ResendParticipantOutcome
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :participant_outcome_id

    validates :participant_outcome_id, presence: true
    validates :qualified_teachers_api_request_successful, inclusion: { in: [false], message: :blank }

    def call
      return if invalid?

      participant_outcome.update!(qualified_teachers_api_request_successful: nil,
                                  sent_to_qualified_teachers_api_at: nil)
    end

  private

    def qualified_teachers_api_request_successful
      participant_outcome&.qualified_teachers_api_request_successful
    end

    def participant_outcome
      @participant_outcome ||= ParticipantOutcome::NPQ.find_by(id: participant_outcome_id)
    end
  end
end
