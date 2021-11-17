# frozen_string_literal: true

module RecordDeclarations
  module NPQ
    extend ActiveSupport::Concern

    STARTED      = "started"
    COMPLETED    = "completed"
    RETAINED_ONE = "retained-1"
    RETAINED_TWO = "retained-2"

    included { extend NPQClassMethods }

    module NPQClassMethods
      def declaration_model
        ParticipantDeclaration::NPQ
      end

      def valid_declaration_types
        [STARTED, COMPLETED, RETAINED_ONE, RETAINED_TWO]
      end
    end
  end
end
