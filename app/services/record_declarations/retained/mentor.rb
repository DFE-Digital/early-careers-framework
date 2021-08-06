# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class Mentor < ::RecordDeclarations::Base
      include RecordDeclarations::Mentor
      include Retained

      def valid_evidence_types
        %w[training-event-attended]
      end
    end
  end
end
