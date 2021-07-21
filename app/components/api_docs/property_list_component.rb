# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/components/api_docs/property_list_component.rb

module ApiDocs
  class PropertyListComponent < ViewComponent::Base
    include ApiDocsHelper
    include MarkdownHelper

    attr_reader :properties

    def initialize(properties)
      super

      @properties = properties
    end
  end
end
