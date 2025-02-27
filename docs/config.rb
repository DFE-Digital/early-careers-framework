# frozen_string_literal: true

require "govuk_tech_docs"
require "lib/govuk_tech_docs/table_of_contents/custom_helpers"
require "lib/govuk_tech_docs/open_api/extension"
require "lib/markdown_renderer"

GovukTechDocs.configure(self)

helpers do
  include GovukTechDocs::TableOfContents::CustomHelpers
end

activate :open_api

set :css_dir, "api-reference/stylesheets"
set :js_dir, "api-reference/javascripts"
set :images_dir, "api-reference/javascripts"
set :markdown,
    renderer: MarkdownRenderer.new(
      with_toc_data: true,
      api: true,
      context: self,
    ),
    fenced_code_blocks: true,
    tables: true,
    no_intra_emphasis: true

set :relative_links, true

set :layout, :custom
