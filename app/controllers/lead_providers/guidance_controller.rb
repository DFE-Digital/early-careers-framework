# frozen_string_literal: true

module LeadProviders
  class GuidanceController < ApplicationController
    def index
      render_content_page :index
    end

    def ecf_usage
      render_content_page :ecf_usage
    end

    def release_notes
      render_content_page :release_notes
    end

    def help
      render_content_page :help
    end

    def render_content_page(page_name)
      @converted_markdown = GovukMarkdown.render(File.read("app/views/lead_providers/guidance/#{page_name}.md")).html_safe
      @page_name = page_name

      render "rendered_markdown_template"
    end
  end
end
