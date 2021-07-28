# frozen_string_literal: true

module RecordDeclarations
  module Started
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include RecordDeclarations::EarlyCareerTeacher
      include StartedCompleted

      class << self
        def schema_validation_params
          super.merge({ schema_path: "ecf/participant_declarations/started" })
        end
      end
    end
  end
end
