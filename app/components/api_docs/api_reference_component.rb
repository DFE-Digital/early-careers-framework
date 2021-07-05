# frozen_string_literal: true

module ApiDocs
  class ApiReferenceComponent < ViewComponent::Base
    def initialize(api_reference)
      super

      @api_reference = api_reference
    end
  end
end
