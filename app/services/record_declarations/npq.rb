# frozen_string_literal: true

module RecordDeclarations
  module NPQ
    extend ActiveSupport::Concern

    included do
      extend NPQClassMethods
    end

    module NPQClassMethods
      def declaration_model
        ParticipantDeclaration::NPQ
      end

      def valid_declaration_types
        %w[started completed retained-1 retained-2]
      end
    end
  end
end
