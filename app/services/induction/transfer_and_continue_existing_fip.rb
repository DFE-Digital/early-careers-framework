# frozen_string_literal: true

class Induction::TransferAndContinueExistingFip < BaseService
  def call
    ActiveRecord::Base.transaction do
      latest_induction_record.leaving!(end_date) if latest_induction_record.active_induction_status?

      enrol_participant_at_new_programme.tap do
        update_mentor_pools_and_mentees if participant_profile.mentor?
      end
    end
  end

private

  attr_reader :end_date, :from_school, :mentor_profile, :participant_profile, :preferred_email,
              :school_cohort, :start_date, :to_school

  def initialize(school_cohort:, participant_profile:, email: nil, start_date: Time.zone.now, end_date: nil, mentor_profile: nil)
    @school_cohort = school_cohort
    @participant_profile = participant_profile
    @preferred_email = email
    @start_date = start_date
    @end_date = end_date || start_date
    @mentor_profile = mentor_profile
    @from_school = latest_induction_record.school
    @to_school = school_cohort.school
    checks!
  end

  def enrol_participant_at_new_programme
    Induction::Enrol.call(participant_profile:,
                          induction_programme:,
                          start_date:,
                          preferred_email:,
                          mentor_profile:,
                          school_transfer: true)
  end

  def update_mentor_pools_and_mentees
    Mentors::ChangeSchool.call(mentor_profile: participant_profile,
                               from_school:,
                               to_school:,
                               remove_on_date: start_date,
                               preferred_email:)
  end

  def checks!
    raise ArgumentError, "Participant is not enrolled in a FIP" unless latest_induction_record.enrolled_in_fip?
    raise ArgumentError, "Participant has no current lead provider" unless lead_provider
    raise ArgumentError, "Participant has no current delivery partner" unless delivery_partner
    raise ArgumentError, "Participant is already enrolled at this school" if from_school == to_school
  end

  def create_induction_programme
    InductionProgramme.full_induction_programme.create!(school_cohort:, partnership:)
  end

  def create_relationship
    Induction::CreateRelationship.call(school_cohort:, lead_provider:, delivery_partner:)
  end

  def current_induction_programme
    @current_induction_programme ||= latest_induction_record&.induction_programme
  end

  def delivery_partner
    @delivery_partner ||= current_induction_programme&.delivery_partner
  end

  def existing_school_induction_programme
    school_cohort.induction_programmes.full_induction_programme.find_by(partnership_id: partnership.id)
  end

  def existing_school_partnership
    to_school.active_partnerships.find_by(cohort: school_cohort.cohort, lead_provider:, delivery_partner:)
  end

  def latest_induction_record
    @latest_induction_record ||= participant_profile.induction_records.latest
  end

  def lead_provider
    @lead_provider ||= current_induction_programme&.lead_provider
  end

  def partnership
    @partnership ||= existing_school_partnership || create_relationship
  end

  def induction_programme
    @induction_programme ||= existing_school_induction_programme || create_induction_programme
  end
end
