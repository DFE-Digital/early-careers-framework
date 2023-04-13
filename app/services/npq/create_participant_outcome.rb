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

    validates :cpd_lead_provider, :participant_external_id, presence: true
    validates :completion_date,
              presence: { message: I18n.t(:missing_completion_date) },
              format: { with: /\d{4}-\d{2}-\d{2}/, message: I18n.t(:invalid_completion_date) }
    validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
    validate :check_for_valid_course_identifiers
    validates :state,
              presence: { message: I18n.t(:missing_state) },
              inclusion: {
                in: ParticipantOutcome::NPQ::PERMITTED_STATES.map(&:to_s),
                message: I18n.t(:invalid_state),
              }
    validate :participant_profile_has_no_completed_declarations

    def call
      return if invalid?

      if participant_outcome_already_exists?
        latest_participant_outcome
      else
        new_participant_outcome.save!
        new_participant_outcome
      end
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentityResolver
                                  .call(
                                    participant_id: participant_external_id,
                                    course_identifier:,
                                    cpd_lead_provider:,
                                  )
    end

  private

    def new_participant_outcome
      @new_participant_outcome ||= ParticipantOutcome::NPQ.new(participant_declaration:, state:, completion_date:)
    end

    def latest_participant_outcome
      @latest_participant_outcome ||= participant_declaration&.outcomes&.latest
    end

    def participant_outcome_already_exists?
      return false if latest_participant_outcome.blank?

      latest_participant_outcome.slice(:state, :completion_date) == new_participant_outcome.slice(:state, :completion_date)
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

      @participant_declarations ||= participant_profile.participant_declarations.npq.valid_to_have_outcome_for_lead_provider_and_course(cpd_lead_provider, course_identifier)
    end

    def participant_profile_has_no_completed_declarations
      return unless participant_profile
      return if participant_declarations.exists?

      errors.add(:base, I18n.t("errors.participant_declarations.completed"))
    end

    def participant_declaration
      @participant_declaration ||= participant_declarations&.first
    end

    def check_for_valid_course_identifiers
      if (::Finance::Schedule::NPQEhco::IDENTIFIERS + ::Finance::Schedule::NPQSupport::IDENTIFIERS).compact.include?(course_identifier)
        errors.add(:course_identifier, I18n.t("errors.participant_outcomes.invalid_course_identifier"))
      end
    end
  end
end
