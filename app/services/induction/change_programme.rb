# frozen_string_literal: true

class Induction::ChangeProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      current_induction_record.changing!(end_date)

      Induction::Enrol.call(participant_profile:,
                            induction_programme: new_induction_programme,
                            start_date:,
                            preferred_email:,
                            mentor_profile:)
      if participant_profile.mentor?
        Mentors::ChangeSchool.call(from_school: current_induction_record.school,
                                   to_school: new_induction_programme.school,
                                   remove_on_date: start_date,
                                   mentor_profile: participant_profile,
                                   preferred_email:)
      end
    end
  end

private

  attr_reader :participant_profile, :new_induction_programme, :start_date, :end_date, :mentor_profile

  def initialize(participant_profile:, end_date:, new_induction_programme:, start_date: Time.zone.now, mentor_profile: nil)
    @participant_profile = participant_profile
    @new_induction_programme = new_induction_programme
    @start_date = start_date
    @end_date = end_date
    @mentor_profile = mentor_profile
    check_cohorts!
  end

  def check_cohorts!
    raise("Given induction programme is not in the cohort of the participant!") unless compatible_cohorts?
  end

  def compatible_cohorts?
    return true if participant_profile.schedule.nil?

    new_induction_programme.cohort_id == participant_profile.schedule.cohort_id
  end

  def current_induction_record
    participant_profile.current_induction_record
  end

  def preferred_email
    current_induction_record&.preferred_identity&.email || participant_profile.participant_identity.email
  end
end
