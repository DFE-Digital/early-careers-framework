# frozen_string_literal: true

module Support
  module ViewComponent
    module ExampleGroup
      extend ActiveSupport::Concern

      included do
        require "capybara/rspec"

        subject(:rendered) { render_inline component }
        let(:_test_context) { Context.new }
      end

      class_methods do
        def stub_component(component_class)
          around do |example|
            component_class.stub!(_test_context)
            example.run
          ensure
            component_class.unstub!
          end
        end
      end

      RSpec.configure do |rspec|
        rspec.include ::ViewComponent::TestHelpers, type: :view_component
        rspec.include self, type: :view_component
        rspec.include Capybara::RSpecMatchers, type: :view_component
      end
    end
  end
end
