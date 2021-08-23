# frozen_string_literal: true

module RecordDeclarations
  module NPQ
    extend ActiveSupport::Concern

    included do
      delegate :npq?, :npq_profiles, to: :user
      extend NPQClassMethods
    end

    def participant?
      npq?
    end

    def user_profile
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course_identifier).first
    end

    module NPQClassMethods
      def declaration_model
        ParticipantDeclaration::NPQ
      end

      def valid_declaration_types
        %w[started completed retained-1 retained-2]
      end
    end

    module NPQClassMethods
      def valid_courses_for_user
        NPQCourse.identifiers
      end
    end
  end
end
