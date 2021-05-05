# frozen_string_literal: true

module Support
  module ComponentsTests
    extend RSpec::Matchers::DSL

    define :render do
      match(&:render?)
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :component
    end
  end
end
