# frozen_string_literal: true

module RecordDeclarations
  module Started
    class Mentor < ::RecordDeclarations::Base
      include Participants::Mentor

      def self.declaration_model
        ParticipantDeclaration::ECF
      end
    end
  end
end
