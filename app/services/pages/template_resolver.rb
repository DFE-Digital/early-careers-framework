# frozen_string_literal: true

module Pages
  class TemplateResolver
    attr_reader :lookup_context

    def initialize(lookup_context)
      @lookup_context = lookup_context
    end

    def resolve(page)
      return nil unless template_exists?(page)

      template(page)
    end

  private

    def template(page)
      "pages/#{page.tr('-', '_')}"
    end

    def template_exists?(page)
      lookup_context.template_exists?(template(page), [], false)
    end
  end
end
