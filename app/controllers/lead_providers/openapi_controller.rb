# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/controllers/api_docs/vendor_api_docs/openapi_controller.rb

module LeadProviders
  class OpenapiController < ApplicationController
    def api_docs
      render plain: LeadProviderApiSpecification.as_yaml, content_type: "text/yaml"
    end
  end
end
