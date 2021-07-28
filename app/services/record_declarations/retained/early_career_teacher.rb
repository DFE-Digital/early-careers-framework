# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include RecordDeclarations::EarlyCareerTeacher
      include Retained

      def schema_validation_params
        super.merge({ schema_path: "ecf/participant_declarations/retained" })
      end
    end
  end
end
