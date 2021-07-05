# frozen_string_literal: true

require "lead_provider_api_specification"

module LeadProviders
  class GuidanceController < ApplicationController
    include MarkdownHelper

    def index
      render_content_page :index
    end

    def ecf_usage
      render_content_page :ecf_usage
    end

    def reference
      @api_reference = ApiDocs::ApiReference.new(LeadProviderApiSpecification.as_hash)
    end

    def release_notes
      render_content_page :release_notes
    end

    def help
      render_content_page :help
    end

    def render_content_page(page_name)
      @converted_markdown = markdown_to_html File.read("app/views/lead_providers/guidance/#{page_name}.md")
      @page_name = page_name

      render "rendered_markdown_template"
    end
  end
end
