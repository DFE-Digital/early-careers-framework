# frozen_string_literal: true

# This is an extension that is automatically added to ViewComponent. We need to be very carefull so
# that we are not modyfying the state of the component (by adding or removing new instance variables)
# as this would make testing less reliable - this is why all the test-related data is instead stored
# in a TestContext object.

module Support
  module ViewComponent
    module TestExtension
      extend ActiveSupport::Concern

      class_methods do
        def new(*args, &block)
          super.tap do |instance|
            test_context.register_component(instance, args) if stubbed?
          end
        end

        def stubbed?
          @test_context.present?
        end

        def stub!(test_context)
          @test_context = test_context
        end

        def unstub!
          remove_instance_variable(:@test_context)
        end

        attr_reader :test_context
      end

      def render_in(view_context)
        return super unless self.class.stubbed?

        view_context.tag(:p, self.class.test_context.output_for(self), class: "stubbed-component")
      end

      ::ViewComponent::Base.prepend(self)
    end
  end
end
