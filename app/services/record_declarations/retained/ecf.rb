# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class ECF < Base
      include RecordDeclarations::ECF

      class << self
        def valid_evidence_types
          %w[training-event-attended self-study-material-completed other].freeze
        end
      end
    end
  end
end
