# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/components/api_docs/api_reference_component.rb

module ApiDocs
  class ApiReferenceComponent < ViewComponent::Base
    def initialize(api_reference)
      super

      @api_reference = api_reference
    end
  end
end
