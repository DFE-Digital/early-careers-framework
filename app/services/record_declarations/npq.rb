# frozen_string_literal: true

module RecordDeclarations
  module NPQ
    extend ActiveSupport::Concern

    included { extend NPQClassMethods }

    module NPQClassMethods
      def declaration_model
        ParticipantDeclaration::NPQ
      end
    end
  end
end
