# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class NPQ < ::RecordDeclarations::Base
      include RecordDeclarations::NPQ
      include Retained

      def schema_validation_params
        super.merge({ schema_path: "npq/participant_declarations/retained" })
      end
    end
  end
end
