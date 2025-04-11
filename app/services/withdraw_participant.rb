# frozen_string_literal: true

class WithdrawParticipant
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :reason
  attribute :course_identifier

  validates :participant_id,
            participant_identity_presence: true
  validates :course_identifier,
            course: true,
            presence: { message: I18n.t(:missing_course_identifier) }
  validates :cpd_lead_provider, induction_record: true
  validates :reason,
            presence: { message: I18n.t(:missing_reason) },
            inclusion: {
              in: ->(klass) { klass.participant_profile.class::WITHDRAW_REASONS.map { |reason| ProgrammeTypeMappings.withdrawal_reason(reason:) } },
              message: I18n.t(:invalid_reason),
            }, if: ->(klass) { klass.participant_profile.present? }
  validate :not_already_withdrawn

  def call
    ActiveRecord::Base.transaction do
      create_withdrawn_participant_profile_state!
      update_withdrawn_induction_record!

      participant_profile.training_status_withdrawn!
    end

    induction_coordinator = relevant_induction_record.school.induction_coordinator_profiles.first
    if induction_coordinator.present?
      SchoolMailer.with(
        induction_record: relevant_induction_record,
        induction_coordinator:,
        partnership: relevant_induction_record.partnership,
      ).fip_provider_has_withdrawn_a_participant.deliver_later
    end

    participant_profile.record_to_serialize_for(lead_provider: cpd_lead_provider.lead_provider)
  end

  def participant_identity
    @participant_identity ||= ParticipantIdentityResolver
                                .call(
                                  participant_id:,
                                  course_identifier:,
                                )
  end

  def participant_profile
    @participant_profile ||=
      ParticipantProfileResolver.call(
        participant_identity:,
        course_identifier:,
      )
  end

  def schedule
    @schedule ||= participant_profile&.schedule_for(cpd_lead_provider:)
  end

private

  def not_already_withdrawn
    return unless participant_profile

    errors.add(:participant_profile, I18n.t(:invalid_withdrawal)) if participant_profile.withdrawn_for?(cpd_lead_provider:)
  end

  def any_participant_declarations_started?
    participant_profile
      .participant_declarations
      .where(
        course_identifier:,
        declaration_type: "started",
      ).exists?
  end

  def relevant_induction_record
    @relevant_induction_record ||= participant_profile.latest_induction_record_for(cpd_lead_provider:)
  end

  def create_withdrawn_participant_profile_state!
    ParticipantProfileState.create!(
      participant_profile:,
      state: ParticipantProfileState.states[:withdrawn],
      cpd_lead_provider:,
      reason:,
    )
  end

  def update_withdrawn_induction_record!
    return unless relevant_induction_record

    Induction::ChangeInductionRecord.call(
      induction_record: relevant_induction_record,
      changes: {
        training_status: ParticipantProfileState.states[:withdrawn],
      },
    )
  end
end
