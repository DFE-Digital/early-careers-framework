# frozen_string_literal: true

module RecordDeclarations
  module Started
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include Participants::EarlyCareerTeacher

      def self.declaration_model
        ParticipantDeclaration::ECF
      end
    end
  end
end
