# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/components/api_docs/schema_component.rb

module ApiDocs
  class SchemaComponent < ViewComponent::Base
    include MarkdownHelper

    attr_reader :schema

    def initialize(schema)
      super

      @schema = schema
    end
  end
end
