# frozen_string_literal: true

module RecordDeclarations
  class NPQ < Base
    delegate :npq?, :npq_profiles, to: :user

    class << self
      def valid_courses
        NPQCourse.identifiers
      end
    end

    def participant?
      npq?
    end

    def user_profile
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course).first
    end

    def schema_validation_params
      super.merge({ schema_path: "npq/participant_declarations" })
    end

    def declaration_type
      ParticipantDeclaration::NPQ
    end

    def actual_lead_provider
      user_profile.validation_data.npq_lead_provider.cpd_lead_provider
    end
  end
end
