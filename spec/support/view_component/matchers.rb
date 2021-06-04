# frozen_string_literal: true

module Support
  module ViewComponent
    module Matchers
      extend RSpec::Matchers::DSL

      define :render do
        match do |rendered|
          rendered.children.any?
        end
      end

      define :have_rendered_component do |component_class|
        match do |rendered|
          @stubs = _test_context.components.select { |stubbed| stubbed.instance.is_a? component_class }
          @matching = @stubs.select { |stubbed| arguments.args_match?(*stubbed.args) }
          @matching.any? do |stubbed|
            rendered.content.include?(stubbed.output)
          end
        end

        chain :with do |*args|
          @arguments = RSpec::Mocks::ArgumentListMatcher.new(*args)
        end

      private

        def arguments
          @arguments ||= RSpec::Mocks::ArgumentListMatcher.new(any_args)
        end
      end

      def have_rendered(object, *args)
        return super unless object.is_a?(Class) && object < ::ViewComponent::Base

        have_rendered_component(object)
      end

      RSpec.configure do |rspec|
        rspec.include self, type: :view_component
      end
    end
  end
end
