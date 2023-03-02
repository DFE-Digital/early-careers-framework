# frozen_string_literal: true

module Multistep
  module Form
    extend ActiveSupport::Concern

    included do
      prepend ValidationContext
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Serialization
      include DateAttribute

      attribute :completed_steps, default: -> { [] }
    end

    class_methods do
      def step(step_name, multiple: false, update: false, &block)
        builder = Builder.new(step_name:, form_class: self, multiple:, update:)
        builder.instance_exec(&block) if block

        steps[step_name] = builder.to_step
      end

      def steps
        @steps ||= {}
      end
    end

    def complete_step(step, attributes = {})
      assign_attributes(attributes)
      return false unless valid?(step)

      self.class.steps[step.to_sym].before_complete(self)
      record_completed_step(step) unless step_completed?(step) && self.class.steps[step].update?
      true
    end

    def reset_steps(*steps)
      new_form = self.class.new
      attributes = self.class.steps.values_at(*steps).flat_map(&:attributes).map(&:to_s)
      assign_attributes(new_form.attributes.slice(*attributes))
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

    def step_completed?(step)
      completed_steps.include?(step)
    end

  private

    def record_completed_step(step)
      if completed_steps&.include?(step) && !self.class.steps[step].multiple?
        self.completed_steps = completed_steps[0..(completed_steps.index(step))]
      else
        completed_steps << step
      end
    end

    module ValidationContext
      def validation_context
        super || :default
      end
    end
  end
end
