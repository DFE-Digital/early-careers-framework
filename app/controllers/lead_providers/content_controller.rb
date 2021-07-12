# frozen_string_literal: true

module LeadProviders
  class ContentController < ApplicationController
    layout :resolve_layout

    def index
      @provider_dashboard_url = dashboard_path
    end

    def partnership_guide
      @page_name = :partnership_guide
    end

  private

    def resolve_layout
      case action_name
      when "index"
        "basic"
      else
        "content_markdown"
      end
    end
  end
end
