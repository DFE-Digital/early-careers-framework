# frozen_string_literal: true

class Induction::TransferToSchoolsProgramme < BaseService
  def call
    check_different_school!

    induction_record = nil

    ActiveRecord::Base.transaction do
      # we haven't already been informed this person is leaving
      if latest_induction_record.active_induction_status?
        latest_induction_record.leaving!(end_date)
      end
      old_school = latest_induction_record.school

      participant_profile.update!(school_cohort:,
                                  schedule:,
                                  cohort_changed_after_payments_frozen:)
      induction_record = Induction::Enrol.call(participant_profile:,
                                               induction_programme:,
                                               start_date:,
                                               preferred_email: email,
                                               mentor_profile:,
                                               schedule:,
                                               school_transfer: true)
      amend_mentor_cohort if participant_profile.ect? && change_mentor_cohort?

      if participant_profile.mentor?
        Mentors::ChangeSchool.call(mentor_profile: participant_profile,
                                   from_school: old_school,
                                   to_school: induction_programme.school,
                                   remove_on_date: start_date,
                                   preferred_email: email)
      end
    end

    induction_record
  end

private

  attr_reader :participant_profile, :induction_programme, :email, :start_date, :end_date, :mentor_profile

  def initialize(participant_profile:, induction_programme:, email: nil, start_date: Time.zone.now, end_date: nil, mentor_profile: nil)
    @participant_profile = participant_profile
    @induction_programme = induction_programme
    @email = email
    @start_date = start_date
    @end_date = end_date || start_date
    @mentor_profile = mentor_profile
  end

  delegate :cohort, :school_cohort, to: :induction_programme

  def amend_mentor_cohort
    Induction::AmendParticipantCohort.new(participant_profile: mentor_profile,
                                          source_cohort_start_year: mentor_profile.schedule.cohort.start_year,
                                          target_cohort_start_year: Cohort.active_registration_cohort.start_year,
                                          force_from_frozen_cohort: true).save
  end

  def change_mentor_cohort?
    !cohort.payments_frozen? && mentor_profile&.unfinished?
  end

  def check_different_school!
    raise ArgumentError, "Participant is already enrolled at this school" if latest_induction_record.school == induction_programme.school
  end

  def cohort_changed_after_payments_frozen
    participant_profile.unfinished_with_billable_declaration?(cohort:)
  end

  def latest_induction_record
    @latest_induction_record ||= participant_profile.induction_records.latest
  end

  def schedule
    @schedule ||= Induction::ScheduleForNewCohort.call(cohort:,
                                                       induction_record: latest_induction_record,
                                                       extended_schedule: cohort_changed_after_payments_frozen)
  end
end
