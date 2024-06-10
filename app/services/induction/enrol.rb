# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    ActiveRecord::Base.transaction do

      unless induction_completed
        record_active_profile_participant_state! unless participant_profile_state_already_correct?
        participant_profile.training_status_active!
        participant_profile.update!(status: :active)
      end

      participant_profile.induction_records.create!(
        induction_programme:,
        start_date:,
        training_status: :active,
        induction_status:,
        schedule: participant_profile.schedule,
        preferred_identity:,
        mentor_profile:,
        school_transfer:,
        appropriate_body_id:,
      )
    end
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date, :preferred_email, :mentor_profile,
              :school_transfer, :appropriate_body_id, :cpd_lead_provider_id, :induction_completed

  # preferred_email can be supplied if the participant_profile.participant_identity does not have
  # the required email for the induction i.e. a participant transferring schools might have a new email
  # address at their new school - really only used for display in the UI
  def initialize(participant_profile:,
                 induction_programme:,
                 start_date: nil,
                 preferred_email: nil,
                 mentor_profile: nil,
                 school_transfer: false,
                 appropriate_body_id: nil,
                 induction_completed: false)
    @participant_profile = participant_profile
    @induction_programme = induction_programme
    @cpd_lead_provider_id = induction_programme&.lead_provider&.cpd_lead_provider_id
    @start_date = start_date || schedule_start_date
    @preferred_email = preferred_email
    @mentor_profile = mentor_profile
    @school_transfer = school_transfer
    @appropriate_body_id = appropriate_body_id || school_appropriate_body_id
    @induction_completed = induction_completed
  end

  def induction_status
    induction_completed ? :completed : :active
  end

  def school_appropriate_body_id
    induction_programme.school_cohort.appropriate_body_id
  end

  def preferred_identity
    if preferred_email.present?
      Identity::Create.call(user: participant_profile.participant_identity.user,
                            email: preferred_email)
    else
      participant_profile.participant_identity
    end
  end

  def record_active_profile_participant_state!
    ParticipantProfileState.create!(participant_profile:,
                                    state: active_participant_profile_state,
                                    cpd_lead_provider_id:)
  end

  def participant_profile_state_already_correct?
    profile_state = participant_profile.participant_profile_states.most_recent

    profile_state.pluck(:state, :cpd_lead_provider_id).last == [active_participant_profile_state, cpd_lead_provider_id]
  end

  def active_participant_profile_state
    ParticipantProfileState.states[:active]
  end

  def schedule_start_date
    participant_profile.schedule.milestones.first.start_date
  end
end
