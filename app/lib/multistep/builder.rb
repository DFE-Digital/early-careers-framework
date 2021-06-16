# frozen_string_literal: true

module Multistep
  class Builder
    def initialize(step_name:, form_class:)
      @step_name = step_name
      @form_class = form_class
      @attributes = []
    end

    attr_reader :attributes

    def attribute(name, *args)
      @attributes << name
      @form_class.attribute name, *args
    end

    %i[validates validate].each do |validation_method|
      define_method validation_method do |*args, **options, &block|
        options[:on] = Array.wrap(options[:on]) << @step_name << :default
        @form_class.public_send(validation_method, *args, **options, &block)
      end
    end

    def next_step(step = nil, &block)
      @next_step = step || block
    end

    def to_step
      Step.new(
        attributes: @attributes,
        next_step: @next_step,
      )
    end
  end
end
