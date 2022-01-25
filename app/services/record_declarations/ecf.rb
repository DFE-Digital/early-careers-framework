# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    STARTED      = "started"
    COMPLETED    = "completed"
    RETAINED_ONE = "retained-1"
    RETAINED_TWO = "retained-2"
    RETAINED_THREE = "retained-3"
    RETAINED_FOUR = "retained-4"

    included do
      extend ECFClassMethods
    end

    module ECFClassMethods
      def declaration_model
        ParticipantDeclaration::ECF
      end

      def valid_declaration_types
        [STARTED, COMPLETED, RETAINED_ONE, RETAINED_TWO, RETAINED_THREE, RETAINED_FOUR]
      end
    end
  end
end
