# frozen_string_literal: true

module RecordDeclarations
  class RecorderFactory
    class << self
      def call(course)
        recorder_klass_name_for_course_identifier(course)
      end

    private

      def recorder_klass_name_for_course_identifier(course)
        declaration_identifiers[course.underscore.intern].to_s
      end

      def declaration_identifiers
        NPQCourseProxy.valid_courses.collect { |identifier| identity_mapping(identifier, "NPQ") }.to_h.merge(
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

  class NPQCourseProxy
    include NPQ
  end
end
