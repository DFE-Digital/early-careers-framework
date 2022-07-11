# frozen_string_literal: true

class Induction::TransferToCorrectSchoolCohort < BaseService
  # we're getting a lot of support queries to update ppts school cohort
  # this is because users are adding ects/mentors to the wrong cohort
  # we can use this to do the basics of a cohort transfer
  # additional checks are needed to make sure all necessary changes have been done
  def call
    participant_profile = get_participant_profile

    return Rails.logger.info "No participant profile with an active training status for #{email}" unless participant_profile

    induction_record = participant_profile.induction_records.latest

    correct_school_cohort = school_cohort_to_switch_to(induction_record)

    return Rails.logger.info "No school cohort to transfer to for #{email}" unless correct_school_cohort

    ActiveRecord::Base.transaction do
      induction_record.update!(induction_programme: correct_school_cohort.default_induction_programme,
                               start_date: start_date_for_cohort,
                               schedule: default_cohort_schedule)
      participant_profile.update!(school_cohort: correct_school_cohort,
                                  schedule: default_cohort_schedule)
    end
  end

  def initialize(email:, cohort:)
    @email = email
    @cohort = cohort
  end

  attr_reader :email, :cohort

private

  def get_user_identity
    ParticipantIdentity.find_by_email(email)
  end

  def get_participant_profile
    ParticipantProfile.find_by(training_status: "active", participant_identity: get_user_identity)
  end

  def school_cohort_to_switch_to(induction_record)
    school = induction_record.school
    SchoolCohort.find_by(school:, cohort:)
  end

  def start_date_for_cohort
    cohort.academic_year_start_date
  end

  def default_cohort_schedule
    Finance::Schedule::ECF.default_for(cohort:)
  end
end
