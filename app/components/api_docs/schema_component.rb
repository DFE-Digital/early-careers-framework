# frozen_string_literal: true

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
