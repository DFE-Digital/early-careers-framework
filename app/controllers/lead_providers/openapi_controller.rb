# frozen_string_literal: true

module LeadProviders
  class OpenapiController < ApplicationController
    def api_docs
      render plain: LeadProviderApiSpecification.as_yaml, content_type: "text/yaml"
    end
  end
end
