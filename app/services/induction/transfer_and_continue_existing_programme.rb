# frozen_string_literal: true

class Induction::TransferAndContinueExistingProgramme < BaseService
  def call
    check_induction_at_different_school!

    induction_record = nil

    ActiveRecord::Base.transaction do
      # we haven't already been informed this person is leaving
      if latest_induction_record.active_induction_status?
        latest_induction_record.leaving!(end_date)
      end

      old_school = latest_induction_record.school

      # create a special programme to support the transferring participant
      programme = create_programme!

      induction_record = Induction::Enrol.call(participant_profile:,
                                               induction_programme: programme,
                                               start_date:,
                                               preferred_email: email,
                                               mentor_profile:,
                                               school_transfer: true)

      if participant_profile.mentor?
        Mentors::ChangeSchool.call(mentor_profile: participant_profile,
                                   from_school: old_school,
                                   to_school: school_cohort.school,
                                   remove_on_date: start_date,
                                   preferred_email: email)
      end
    end

    induction_record
  end

private

  attr_reader :school, :participant_profile, :email, :start_date, :end_date, :mentor_profile, :latest_induction_record

  def initialize(school:, participant_profile:, email: nil, start_date: Time.zone.now, end_date: nil, mentor_profile: nil)
    @school = school
    @participant_profile = participant_profile
    @email = email
    @start_date = start_date
    @end_date = end_date || start_date
    @mentor_profile = mentor_profile
    @latest_induction_record = participant_profile.induction_records.latest
  end

  def create_programme!
    if latest_induction_record.enrolled_in_fip?
      partnership = partnership_at_new_school || create_relationship
      InductionProgramme.find_or_create_by!(training_programme: :full_induction_programme,
                                            school_cohort:,
                                            partnership:)
    elsif latest_induction_record.enrolled_in_cip?
      InductionProgramme.find_or_create_by!(training_programme: :core_induction_programme,
                                            school_cohort:,
                                            core_induction_programme: current_induction_programme.core_induction_programme)
    else
      raise "Not enrolled in a FIP or CIP currently"
    end
  end

  def create_relationship
    if lead_provider.present?
      Induction::CreateRelationship.call(school_cohort:,
                                         lead_provider:,
                                         delivery_partner:)
    end
  end

  def partnership_at_new_school
    Partnership.find_by(school:, cohort:, lead_provider:, delivery_partner:)
  end

  def current_induction_programme
    latest_induction_record&.induction_programme
  end

  def lead_provider
    current_induction_programme&.lead_provider
  end

  def delivery_partner
    current_induction_programme&.delivery_partner
  end

  def cohort
    @cohort ||= participant_profile.schedule.cohort
  end

  def school_cohort
    @school_cohort ||= school.school_cohorts.find_by(cohort:)
  end

  def check_induction_at_different_school!
    raise ArgumentError, "Participant is already enrolled at this school" if latest_induction_record.school == school
  end
end
