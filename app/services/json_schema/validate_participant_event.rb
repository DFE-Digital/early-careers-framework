# frozen_string_literal: true

require "json_schema/base"

module JsonSchema
  class ValidateParticipantEvent < Base
    def default_config
      super.merge(
        {
          version: "0.2",
          schema_path: "ecf/participant_declarations",
        },
      )
    end
  end
end
