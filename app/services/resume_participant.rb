# frozen_string_literal: true

class ResumeParticipant
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :course_identifier

  validates :cpd_lead_provider,
            induction_record: true
  validates :course_identifier, course: true
  validate :not_already_active
  validate :not_already_withdrawn

  def call
    ActiveRecord::Base.transaction do
      create_active_participant_profile_state!
      create_active_induction_record!
      participant_profile.training_status_active!
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
    participant_profile&.schedule_for(cpd_lead_provider:)
  end

private

  def not_already_active
    return unless participant_profile

    errors.add(:participant_profile, I18n.t(:already_active)) if participant_profile.active_for?(cpd_lead_provider:)
  end

  def not_already_withdrawn
    return unless participant_profile

    errors.add(:participant_profile, I18n.t(:invalid_withdrawal)) if participant_profile.withdrawn_for?(cpd_lead_provider:)
  end

  def relevant_induction_record
    @relevant_induction_record ||= Induction::FindBy.call(participant_profile:, lead_provider: cpd_lead_provider.lead_provider)
  end

  def create_active_participant_profile_state!
    ParticipantProfileState.create!(
      participant_profile:,
      state: ParticipantProfileState.states[:active],
      cpd_lead_provider:,
    )
  end

  def create_active_induction_record!
    return unless relevant_induction_record

    Induction::ChangeInductionRecord.call(
      induction_record: relevant_induction_record,
      changes: {
        training_status: "active",
      },
    )
  end
end
