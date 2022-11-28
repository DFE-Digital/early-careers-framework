# frozen_string_literal: true

class WithdrawParticipant
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :reason
  attribute :course_identifier

  validates :cpd_lead_provider, induction_record: true
  validates :reason,
            presence: { message: I18n.t(:missing_reason) },
            inclusion: {
              in: ->(klass) { klass.participant_profile.class::WITHDRAW_REASONS },
              message: I18n.t(:invalid_reason),
            }, if: ->(klass) { klass.participant_profile.present? }
  validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
  validate :not_already_withdrawn
  validate :with_started_participant_declarations

  def call
    ActiveRecord::Base.transaction do
      create_withdrawn_participant_profile_state!
      update_withdrawn_induction_record!

      participant_profile.training_status_withdrawn!
    end

    unless participant_profile.npq?
      induction_coordinator = participant_profile.school.induction_coordinator_profiles.first
      SchoolMailer.fip_provider_has_withdrawn_a_participant(withdrawn_participant: participant_profile, induction_coordinator:).deliver_later
    end

    participant_profile.record_to_serialize_for(lead_provider: cpd_lead_provider.lead_provider)
  end

  def participant_identity
    @participant_identity ||= ParticipantIdentity.find_by(external_identifier: participant_id)
  end

  def participant_profile
    @participant_profile ||=
      ParticipantProfileResolver.call(
        participant_identity:,
        course_identifier:,
        cpd_lead_provider:,
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

  def with_started_participant_declarations
    return unless participant_profile && participant_profile.npq?

    errors.add(:participant_profile, I18n.t(:no_started_declaration_found)) unless any_participant_declarations_started?
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
