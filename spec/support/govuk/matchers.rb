# frozen_string_literal: true

module Support
  module Govuk
    module ViewMatchers
      extend RSpec::Matchers::DSL

      define :have_govuk_tag do |text, color: nil|
        match do |rendered|
          classes = %w[.govuk-tag]
          # TODO: blue means either `govuk-tag--blue` or no `govuk-tag-*` class
          classes << ".govuk-tag--#{color}" if color
          expect(rendered).to have_selector classes.join, text: /\A#{text}\z/i
        end
      end

      RSpec.configure do |rspec|
        rspec.include self, type: :view_component
      end
    end
  end
end
