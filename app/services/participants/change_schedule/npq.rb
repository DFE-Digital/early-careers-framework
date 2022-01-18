# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class NPQ < Base
      def self.valid_courses
        NPQCourse.identifiers
      end

    private

      def user_profile
        user&.npq_profiles&.active_record&.includes({ npq_application: [:npq_course] })&.where('npq_courses.identifier': course_identifier)&.first
      end

      def matches_lead_provider?
        cpd_lead_provider == user_profile&.npq_application&.npq_lead_provider&.cpd_lead_provider
      end
    end
  end
end
