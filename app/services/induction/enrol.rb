# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    # TODO: The participant_profile could already have an induction record already in play
    # that we could update with an end_date / status
    participant_profile.induction_records.create!(induction_programme: induction_programme,
                                                  start_date: start_date,
                                                  status: :active,
                                                  schedule: participant_profile.schedule)
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date

  def initialize(participant_profile:, induction_programme: nil, start_date: nil)
    @participant_profile = participant_profile
    @induction_programme = induction_programme || default_induction_programme
    @start_date = start_date || schedule_start_date
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
