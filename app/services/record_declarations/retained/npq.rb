# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class NPQ < Base
      include Participants::NPQ
      include RecordDeclarations::NPQ

      class << self
        def valid_evidence_types
          %w[yes].freeze
        end
      end
    end
  end
end
