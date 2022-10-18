# frozen_string_literal: true

class UserProfileResolver
  class << self
    def call(user:, course_identifier:, cpd_lead_provider:)
      return unless user

      case course_identifier
      when "ecf-induction"
        user&.early_career_teacher_profile
      when "ecf-mentor"
        user&.mentor_profile
      when NPQCourse.identifiers.include?(course_identifier)
        user
          .npq_profiles
          .active_record
          .includes({ npq_application: [:npq_course] })
          .where('npq_courses.identifier': course_identifier)
          .where({ npq_application: { npq_lead_provider: cpd_lead_provider.npq_lead_provider } })
          .first
      end
    end
  end
end
