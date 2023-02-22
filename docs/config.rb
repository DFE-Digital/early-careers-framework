# frozen_string_literal: true

require "govuk_tech_docs"
require "lib/govuk_tech_docs/table_of_contents/custom_helpers"
require "lib/govuk_tech_docs/open_api/extension"

GovukTechDocs.configure(self)

helpers do
  include GovukTechDocs::TableOfContents::CustomHelpers
end

activate :open_api

set :css_dir, "stylesheets"
set :js_dir, "javascripts"

after_build do |build|
  Middleman::Cli::Build.source_root(File.dirname(__FILE__))

  build.thor.source_paths << "#{File.dirname(__FILE__)}/source"

  %w[stylesheets javascripts].each do |type|
    build.thor.directory(File.join(type), File.join(config[:build_dir], "api-reference", type))
  end
end

set :relative_links, true
