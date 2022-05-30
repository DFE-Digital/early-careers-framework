# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    ActiveRecord::Base.transaction do
      participant_profile.induction_records.create!(
        induction_programme: induction_programme,
        start_date: start_date,
        training_status: :active,
        induction_status: :active,
        schedule: participant_profile.schedule,
        preferred_identity: preferred_identity,
        mentor_profile: mentor_profile,
        school_transfer: school_transfer,
      )
      # TODO: here would be a convenient place to reactivate a withdrawn / deferred profile
      # However this needs some checking/work by the LP team
      # reactivate_profile! unless participant_profile.active_training_status?
    end
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date, :preferred_email, :mentor_profile, :school_transfer

  # preferred_email can be supplied if the participant_profile.participant_identity does not have
  # the required email for the induction i.e. a participant transferring schools might have a new email
  # address at their new school - really only used for display in the UI
  def initialize(participant_profile:, induction_programme:, start_date: nil, preferred_email: nil, mentor_profile: nil, school_transfer: false)
    @participant_profile = participant_profile
    @induction_programme = induction_programme
    @start_date = start_date || schedule_start_date
    @preferred_email = preferred_email
    @mentor_profile = mentor_profile
    @school_transfer = school_transfer
  end

  def preferred_identity
    if preferred_email.present?
      Identity::Create.call(user: participant_profile.participant_identity.user,
                            email: preferred_email)
    else
      participant_profile.participant_identity
    end
  end

  def schedule_start_date
    participant_profile.schedule.milestones.first.start_date
  end

  def reactivate_profile!
    ParticipantProfileState.create!(participant_profile: participant_profile,
                                    state: ParticipantProfileState.states[:active],
                                    cpd_lead_provider: induction_programme.lead_provider&.cpd_lead_provider)
  end
end
