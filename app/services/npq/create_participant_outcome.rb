# frozen_string_literal: true

module NPQ
  class CreateParticipantOutcome
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :cpd_lead_provider
    attribute :participant_external_id
    attribute :course_identifier
    attribute :state
    attribute :completion_date, :date

    validates :cpd_lead_provider, :completion_date, :participant_external_id, :course_identifier, presence: true
    validates :completion_date, future_date: true
    validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
    validates :state,
              presence: { message: I18n.t(:missing_state) },
              inclusion: {
                in: ParticipantOutcome::NPQ::VALID_STATES.map(&:to_s),
                message: I18n.t(:invalid_state),
              }
    validate :participant_profile_has_no_completed_declarations

    def new_participant_outcome
      @new_participant_outcome ||= ParticipantOutcome::NPQ.new(participant_declaration:, state:, completion_date:)
    end

    def valid_to_save?
      return true if participant_declaration&.outcomes.blank?

      participant_declaration.outcomes.latest.slice(:state, :completion_date) != new_participant_outcome.slice(:state, :completion_date)
    end

    def call
      return if invalid?

      new_participant_outcome.save! if valid_to_save?
      participant_declaration.outcomes.latest
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentity.find_by(external_identifier: participant_external_id)
    end

    def participant_profile
      @participant_profile ||= ParticipantProfileResolver
                                .call(
                                  participant_identity:,
                                  course_identifier:,
                                  cpd_lead_provider:,
                                )
    end

    def participant_declarations
      return unless participant_profile

      @participant_declarations ||= participant_profile.participant_declarations.npq.for_declaration("completed").order(declaration_date: :desc)
    end

    def participant_profile_has_no_completed_declarations
      return unless participant_profile && participant_declarations.blank?

      errors.add(:base, I18n.t("errors.participant_declarations.completed"))
    end

    def participant_declaration
      return unless participant_declarations

      @participant_declaration ||= participant_declarations.first
    end
  end
end
