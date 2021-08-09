# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include RecordDeclarations::EarlyCareerTeacher
      include Retained

      def valid_evidence_types
        %w[training-event-attended self-study-material-completed other]
      end
    end
  end
end
