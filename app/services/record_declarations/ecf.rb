# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    included do
      extend ECFClassMethods
    end

    module ECFClassMethods
      def declaration_model
        ParticipantDeclaration::ECF
      end

      def valid_declaration_types
        %w[started completed retained-1 retained-2 retained-3 retained-4]
      end
    end

    def declaration_model
      self.class.declaration_model
    end

    def valid_declarations_types
      self.class.valid_declaration_type
    end
  end
end
