# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class SwaggerApiDocsPage < ::Pages::BasePage
    set_url "/api-docs"
    set_primary_heading "Manage teacher CPD - lead provider API"

    element :header, "h2"
  end
end
