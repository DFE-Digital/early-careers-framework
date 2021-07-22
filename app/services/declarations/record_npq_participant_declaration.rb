# frozen_string_literal: true

module Declarations
  class RecordNPQParticipantDeclaration < RecordParticipantDeclaration
    def course_valid_for_participant?
      %w[npq-leading-teaching
         npq-leading-teaching-development
         npq-leading-behaviour-culture
         npq-headship
         npq-senior-leadership
         npq-executive-leadership].include?(course)
    end

    def user_profile
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course).first
    end

    def declaration_type
      ParticipantDeclaration::NPQ
    end

    def actual_lead_provider
      user_profile.validation_data.npq_lead_provider.cpd_lead_provider if npq?
    end
  end
end
