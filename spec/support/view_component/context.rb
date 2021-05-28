# frozen_string_literal: true

module Support
  module ViewComponent
    class Context
      StubbedComponent = Struct.new(:instance, :args, :output)

      def register_component(instance, args)
        components << StubbedComponent.new(
          instance,
          args,
          "--#{Random.uuid}--",
        )
      end

      def output_for(instance)
        components.find { |comp| comp.instance == instance }.output
      end

      def components
        @components ||= []
      end
    end
  end
end
