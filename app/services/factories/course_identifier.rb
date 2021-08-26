# frozen_string_literal: true

module Factories
  class CourseIdentifier
    class << self
      def call(course)
        recorder_klass_name_for_course_identifier(course).presence || (raise ActionController::ParameterMissing, I18n.t(:invalid_course))
      end

    private

      def recorder_klass_name_for_course_identifier(course)
        declaration_identifiers[course.underscore.intern].to_s
      end

      def declaration_identifiers
        NPQCourse.identifiers.collect { |identifier| identity_mapping(identifier, "NPQ") }.to_h.merge(
          {
            ecf_induction: "EarlyCareerTeacher",
            ecf_mentor: "Mentor",
          },
        )
      end

      def identity_mapping(name, klass)
        [name.underscore.intern, klass]
      end
    end
  end
end
