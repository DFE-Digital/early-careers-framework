# frozen_string_literal: true

module RecordDeclarations
  module Started
    class NPQ < ::RecordDeclarations::Base
      include RecordDeclarations::NPQ
      include StartedCompleted

      class << self
        def schema_validation_params
          super.merge({ schema_path: "npq/participant_declarations/started" })
        end
      end
    end
  end
end
