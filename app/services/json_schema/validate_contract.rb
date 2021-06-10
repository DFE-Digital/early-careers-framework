# frozen_string_literal: true

require "json_schema/base"

module JsonSchema
  class ValidateContract < Base
    include InitializeWithConfig

  private

    def default_config
      super.merge(
        {
          schema_path: "ecf/contracts",
        },
      )
    end
  end
end
