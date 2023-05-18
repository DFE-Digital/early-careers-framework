# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/controllers/api_docs/vendor_api_docs/openapi_controller.rb

require "lead_provider_api_specification"

module LeadProviders
  class OpenapiController < ApplicationController
    def api_docs
      render plain: LeadProviderApiSpecification.as_yaml(version_param), content_type: "text/yaml"
    end

  private

    def version_param
      params[:api_version] || LeadProviderApiSpecification::CURRENT_VERSION
    end
  end
end
