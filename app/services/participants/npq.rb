# frozen_string_literal: true

module Participants
  module NPQ
    extend ActiveSupport::Concern

    included do
      delegate :npq_application, :participant_profile_state, to: :user_profile, allow_nil: true
      extend NPQClassMethods
    end

    def matches_lead_provider?
      cpd_lead_provider == npq_application&.npq_lead_provider&.cpd_lead_provider
    end

    def participant?
      user_profile.present?
    end

    def user_profile
      return unless participant_identity

      @user_profile ||= ParticipantProfile::NPQ
        .includes(npq_application: :npq_course)
        .where(participant_identity: participant_identity)
        .npqs
        .active_record
        .where('npq_courses.identifier': course_identifier)
        .first
    end

    module NPQClassMethods
      def valid_courses
        NPQCourse.identifiers
      end
    end
  end
end
