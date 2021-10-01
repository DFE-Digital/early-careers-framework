# frozen_string_literal: true

require "govuk_tech_docs"
require "lib/govuk_tech_docs/open_api/extension"

GovukTechDocs.configure(self)

activate :open_api

# set :images_dir, "api-reference"
set :css_dir, "api-reference/stylesheets"
set :js_dir, "api-reference/javascripts"
set :images_dir, "api-reference/javascripts"

# set :http_prefix, "api-reference"
configure :build do
  # set :http_prefix, '/api-reference'
  # set :css_dir, "stylesheets"
  # set :js_dir, "javascripts"
end
set :relative_links, true
