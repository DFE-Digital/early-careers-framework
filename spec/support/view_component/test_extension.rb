module Support
  module ViewComponent
    module TestExtension
      extend ActiveSupport::Concern

      class_methods do
        def new(*args, &block)
          instance = super
          test_context.register_component(instance, args) if stubbed?
          instance
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

        view_context.content_tag(:p, test_context.output_for(self), class: "stubbed-component")
      end

    private

      delegate :test_context, to: :class

      ::ViewComponent::Base.prepend(self)
    end
  end
end
