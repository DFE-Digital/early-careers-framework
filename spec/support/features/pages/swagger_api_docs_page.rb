# frozen_string_literal: true

require_relative "./base"

module Pages
  class SwaggerApiDocsPage < ::Pages::Base
    set_url "/api-docs"
    set_primary_heading "Manage teacher CPD - lead provider API"

    element :header, "h2"
  end
end
