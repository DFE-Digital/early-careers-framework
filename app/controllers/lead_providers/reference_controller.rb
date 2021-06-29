# frozen_string_literal: true

require "lead_provider_api_specification"

module LeadProviders
  class ReferenceController < ApplicationController
    def reference
      @api_reference = ApiDocs::ApiReference.new(LeadProviderApiSpecification.as_hash)
    end

    def home
      render_content_page :home
    end

    def release_notes
      render_content_page :release_notes
    end

    def help
      render_content_page :help
    end

    def render_content_page(page_name)
      @converted_markdown = GovukMarkdown.render(File.read("app/views/lead_providers/reference/#{page_name}.md")).html_safe
      @page_name = page_name

      render "rendered_markdown_template"
    end
  end
end
