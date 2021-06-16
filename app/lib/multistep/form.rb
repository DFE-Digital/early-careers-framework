# frozen_string_literal: true

require_dependency "multistep/builder"
require_dependency "multistep/step"

module Multistep
  module Form
    extend ActiveSupport::Concern

    included do
      prepend ValidationContext
      include ActiveModel::Attributes
      include ActiveModel::Serialization

      attribute :completed_steps, default: []
    end

    class_methods do
      def step(step_name, &block)
        builder = Builder.new(step_name: step_name, form_class: self)
        builder.instance_exec(&block) if block

        steps[step_name] = builder.to_step
      end

      def steps
        @steps ||= {}
      end
    end

    def record_completed_step(step)
      if completed_steps.include? step
        self.completed_steps = completed_steps[0..completed_steps.index(step)]
      else
        completed_steps << step
      end
    end

    def previous_step(from: nil)
      step_index = completed_steps.index(from)
      return completed_steps.last if step_index.nil?
      return if step_index.zero?

      completed_steps[step_index - 1]
    end

    def next_step(from: previous_step)
      return self.class.steps.keys.first if from.blank?

      step_definition = self.class.steps[previous_step]
      step_definition.next_step(self)
    end

    def completed_steps=(value)
      super(value.map(&:to_sym))
    end

    module ValidationContext
      def validation_context
        super || :default
      end
    end
  end
end
