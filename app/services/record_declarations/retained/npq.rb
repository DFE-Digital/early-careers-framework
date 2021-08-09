# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class NPQ < ::RecordDeclarations::Base
      include RecordDeclarations::NPQ
      include Retained

      def valid_evidence_types
        %w[yes]
      end
    end
  end
end
