# frozen_string_literal: true

module RecordDeclarations
  class RecorderFactory
    class << self
      def call(course)
        recorder_klass_for_course_identifier(course)
      end

    private

      def recorder_klass_for_course_identifier(course)
        declaration_identifiers[course.underscore.intern].to_s.constantize
      end

      def declaration_identifiers
        NPQ.valid_courses.collect { |identifier| identity_mapping(identifier, NPQ) }.to_h.merge(
          {
            ecf_induction: ECF::EarlyCareerTeacher,
            ecf_mentor: ECF::Mentor,
          },
        )
      end

      def identity_mapping(name, klass)
        [name.underscore.intern, klass.name]
      end
    end
  end
end
