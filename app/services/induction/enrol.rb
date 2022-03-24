# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    participant_profile.induction_records.create!(
      induction_programme: induction_programme,
      start_date: start_date,
      status: :active,
      schedule: participant_profile.schedule,
      preferred_identity: preferred_identity,
      # FIXME: waiting for rebase
      # mentor_profile: mentor_profile,
    )
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date, :preferred_identity, :mentor_profile

  # preferred_identity can be suppied if the participant_profile.participant_identity does not have
  # the required email for the induction i.e. a participant transferring schools might have a new email
  # address at their new school - really only useed for display in the UI
  def initialize(participant_profile:, induction_programme:, start_date: nil, preferred_identity: nil, mentor_profile: nil)
    @participant_profile = participant_profile
    @induction_programme = induction_programme
    @start_date = start_date || schedule_start_date
    @preferred_identity = preferred_identity || participant_profile.participant_identity
    @mentor_profile = mentor_profile
  end

  def schedule_start_date
    participant_profile.schedule.milestones.first.start_date
  end
end
