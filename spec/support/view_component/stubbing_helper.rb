# frozen_string_literal: true

module Support
  module ViewComponent
    module StubbingHelper
      extend ActiveSupport::Concern

      included do
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
    end
  end
end
