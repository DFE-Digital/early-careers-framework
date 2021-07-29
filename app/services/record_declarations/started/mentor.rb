# frozen_string_literal: true

module RecordDeclarations
  module Started
    class Mentor < ::RecordDeclarations::Base
      include RecordDeclarations::Mentor
      include StartedCompleted

      class << self
        def schema_validation_params
          super.merge({ schema_path: "ecf/participant_declarations/started" })
        end
      end
    end
  end
end
