# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/components/api_docs/operation_component.rb

module ApiDocs
  class OperationComponent < ViewComponent::Base
    include MarkdownHelper
    include ApiDocsHelper

    attr_reader :operation

    def initialize(operation)
      super

      @operation = operation
    end
  end
end
