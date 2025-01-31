# frozen_string_literal: true

module Finance
  module ECF
    class OutputCalculator
      COHORT_WITH_NO_MENTOR_FUNDING_DECLARATION_CLASS_TYPES = ["ParticipantDeclaration::ECT", "ParticipantDeclaration::Mentor"].freeze

      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def participant_declaration_class_types
        @participant_declaration_class_types ||= statement.cohort.mentor_funding? ? self.class::COHORT_WITH_MENTOR_FUNDING_DECLARATION_CLASS_TYPES : COHORT_WITH_NO_MENTOR_FUNDING_DECLARATION_CLASS_TYPES
      end
    end
  end
end
