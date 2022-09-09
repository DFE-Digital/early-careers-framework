# frozen_string_literal: true

class Induction::TransferToSchoolsProgramme < BaseService
  def call
    check_different_school!

    ActiveRecord::Base.transaction do
      # we haven't already been informed this person is leaving
      if latest_induction_record.active_induction_status?
        latest_induction_record.leaving!(end_date)
      end
      old_school = latest_induction_record.school

      Induction::Enrol.call(participant_profile:,
                            induction_programme:,
                            start_date:,
                            preferred_email: email,
                            mentor_profile:,
                            school_transfer: true)

      if participant_profile.mentor?
        Mentors::ChangeSchool.call(mentor_profile: participant_profile,
                                   from_school: old_school,
                                   to_school: induction_programme.school,
                                   remove_on_date: start_date,
                                   preferred_email: email)
      end
    end
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

  def latest_induction_record
    participant_profile.induction_records.latest
  end

  def check_different_school!
    raise ArgumentError, "Participant is already enrolled at this school" if latest_induction_record.school == induction_programme.school
  end
end
