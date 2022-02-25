# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    participant_profile.induction_records.create!(induction_programme: induction_programme,
                                                  start_date: start_date,
                                                  status: :active,
                                                  schedule: participant_profile.schedule,
                                                  registered_identity: registered_identity)
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date, :registered_identity

  # registered_identity can be suppied if the participant_profile.participant_identity does not have
  # the required email for the induction i.e. a participant transferring schools might have a new email
  # address at their new school - really only useed for display in the UI
  def initialize(participant_profile:, induction_programme: nil, start_date: nil, registered_identity: nil)
    @participant_profile = participant_profile
    @induction_programme = induction_programme || default_induction_programme
    @start_date = start_date || schedule_start_date
    @registered_identity = registered_identity || participant_profile.participant_identity
  end

  def schedule_start_date
    participant_profile.schedule.milestones.first.start_date
  end

  def default_induction_programme
    # FIXME: we need to navigate to the school_cohort - currently there is a direct link
    # but when that goes we'd need to either pass that in or use the teacher_profile
    # assuming that is populated correctly or something else
    # participant_profile.teacher_profile.school
    #
    participant_profile.school_cohort.default_induction_programme
  end
end
