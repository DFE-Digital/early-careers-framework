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
    end
  end
end
