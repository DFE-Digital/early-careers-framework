# frozen_string_literal: true

require "lead_provider_api_specification"

module LeadProviders
  class GuidanceController < ApplicationController
    layout :resolve_layout

    def index
      @page_name = :index
    end

    def ecf_usage
      @page_name = :ecf_usage
    end

    def reference
      @page_name = :reference
      @api_reference = ApiDocs::ApiReference.new(LeadProviderApiSpecification.as_hash)
    end

    def release_notes
      @page_name = :release_notes
    end

    def help
      @page_name = :help
    end

  private

    def resolve_layout
      case action_name
      when "reference"
        "application"
      else
        "guidance_markdown"
      end
    end
  end
end
