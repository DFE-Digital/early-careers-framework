# frozen_string_literal: true

class DeferParticipant
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :reason
  attribute :course_identifier

  validates :cpd_lead_provider,
            induction_record: true
  validates :reason,
            presence: { message: I18n.t(:missing_reason) },
            inclusion: {
              in: ParticipantProfile::DEFERRAL_REASONS,
              message: I18n.t(:invalid_reason),
            }
  validates :course_identifier, course: true
  validate :not_already_deferred
  validate :not_already_withdrawn

  def call
    ActiveRecord::Base.transaction do
      create_deferred_participant_profile_state!
      create_deferred_induction_record!
      participant_profile.training_status_deferred!
    end

    participant_profile.record_to_serialize_for(lead_provider: cpd_lead_provider.lead_provider)
  end

  def participant_identity
    @participant_identity ||= ParticipantIdentityResolver
                                .call(
                                  user_id: participant_id,
                                  course_identifier:,
                                  cpd_lead_provider:,
                                )
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
    participant_profile&.schedule_for(cpd_lead_provider:)
  end

private

  def not_already_deferred
    return unless participant_profile

    errors.add(:participant_profile, I18n.t(:invalid_deferral)) if participant_profile.deferred_for?(cpd_lead_provider:)
  end

  def not_already_withdrawn
    return unless participant_profile

    errors.add(:participant_profile, I18n.t(:invalid_withdrawal)) if participant_profile.withdrawn_for?(cpd_lead_provider:)
  end

  def relevant_induction_record
    @relevant_induction_record ||= participant_profile.latest_induction_record_for(cpd_lead_provider:)
  end

  def create_deferred_participant_profile_state!
    ParticipantProfileState.create!(
      participant_profile:,
      state: ParticipantProfileState.states[:deferred],
      cpd_lead_provider:,
      reason:,
    )
  end

  def create_deferred_induction_record!
    return unless relevant_induction_record

    Induction::ChangeInductionRecord.call(
      induction_record: relevant_induction_record,
      changes: {
        training_status: "deferred",
      },
    )
  end
end
