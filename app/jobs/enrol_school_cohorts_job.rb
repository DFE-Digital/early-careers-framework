# frozen_string_literal: true

class EnrolSchoolCohortsJob < ApplicationJob
  def perform
    SchoolCohort
      .where(induction_programme_choice: InductionProgramme.training_programmes.keys)
      .left_joins(:induction_programmes)
      .where(induction_programmes: { id: nil })
      .find_each do |sc|
        choice = sc.induction_programme_choice
        programme = InductionProgramme.new(school_cohort: sc,
                                           training_programme: choice)
        case choice
        when "full_induction_programme"
          programme.partnership = sc.school.partnerships.active.where(cohort: sc.cohort).first
        when "core_induction_programme"
          programme.core_induction_programme = sc.core_induction_programme
        end
        programme.save!

        sc.ecf_participant_profiles.each do |profile|
          induction_record = Induction::Enrol.call(participant_profile: profile, induction_programme: programme)
          induction_record.update!(induction_status: profile.status,
                                   training_status: profile.training_status,
                                   mentor_profile_id: profile.mentor_profile_id)
          Mentors::AddToSchool.call(school: sc.school, mentor_profile: profile) if profile.mentor?
        end
        sc.update!(default_induction_programme: programme)

        Rails.logger.info "Added #{choice} to #{sc.school.urn}"
      end
  end
end
