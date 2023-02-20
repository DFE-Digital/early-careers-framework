# frozen_string_literal: true

module NPQ
  class VoidParticipantOutcome
    def initialize(participant_declaration)
      @participant_declaration = participant_declaration
    end

    def call
      return unless create_participant_outcome?
      return if latest_participant_outcome&.voided?

      ParticipantOutcome::NPQ.create!(
        participant_declaration:,
        completion_date: declaration_date,
        state: "voided",
      )
    end

  private

    attr_reader :participant_declaration

    delegate :course_identifier, :participant_profile,
             :declaration_date, :declaration_type,
             to: :participant_declaration

    def create_participant_outcome?
      participant_profile&.npq? &&
        declaration_type == "completed" &&
        valid_course_identifier_for_participant_outcome?
    end

    def valid_course_identifier_for_participant_outcome?
      !(
        ::Finance::Schedule::NPQEhco::IDENTIFIERS +
        ::Finance::Schedule::NPQSupport::IDENTIFIERS
      ).compact.include?(course_identifier)
    end

    def latest_participant_outcome
      participant_declaration&.outcomes&.latest
    end
  end
end
