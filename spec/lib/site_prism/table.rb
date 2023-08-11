# frozen_string_literal: true

# lifted from https://github.com/investtools/site_prism-table/blob/master/lib/site_prism/table.rb

require "nokogiri"

module SitePrism
  module Table
    autoload :Element,    "lib/site_prism/table/element"
    autoload :Definition, "lib/site_prism/table/definition"

    def table(name, *selector, &block)
      definition = Definition.new(&block)
      define_method name do
        Element.new(page.find(*selector).native.inner_html, definition)
      end
    end
  end
end
