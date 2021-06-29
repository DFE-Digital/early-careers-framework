# frozen_string_literal: true

module ApiDocs
  class SchemaComponent < ViewComponent::Base
    include MarkdownHelper

    attr_reader :schema

    def initialize(schema)
      @schema = schema
    end
  end
end
