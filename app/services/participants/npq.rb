# frozen_string_literal: true

module Participants
  module NPQ
    extend ActiveSupport::Concern

    included do
      delegate :validation_data, :participant_profile_state, to: :user_profile, allow_nil: true
      delegate :npq?, :npq_profile, to: :user, allow_nil: true
      extend NPQClassMethods
    end

    def matches_lead_provider?
      cpd_lead_provider == validation_data&.npq_lead_provider&.cpd_lead_provider
    end

    def participant?
      npq?
    end

    def user_profile
      npq_profiles&.active_record&.includes({ validation_data: [:npq_course] })&.where('npq_courses.identifier': course_identifier)&.first
    end

    module NPQClassMethods
      def valid_courses
        NPQCourse.identifiers
      end
    end
  end
end
