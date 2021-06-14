require_dependency 'multistep/builder'

module Multistep
  module Form
    extend ActiveSupport::Concern

    included do
      prepend ValidationContext
    end

    class_methods do
      def step(step_name, &block)
        builder = Builder.new(step_name: step_name, form_class: self)
        builder.instance_exec(&block)

        steps[step_name] = builder.attributes
      end

      def steps
        @steps ||= {}
      end
    end

    module ValidationContext
      def validation_context
        super || :default
      end
    end
  end
end
