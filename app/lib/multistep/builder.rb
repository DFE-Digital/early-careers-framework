# frozen_string_literal: true

module Multistep
  class Builder
    def initialize(step_name:, form_class:, multiple: false, update: false)
      @step_name = step_name
      @form_class = form_class
      @multiple = multiple
      @update = update
      @attributes = []
    end

    attr_reader :attributes

    def attribute(name, *args)
      @attributes << name
      @form_class.attribute name, *args
    end

    def before_complete(callback = nil, &block)
      @before_complete = callback&.to_proc || block
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
        multiple: @multiple,
        attributes: @attributes,
        next_step: @next_step,
        before_complete: @before_complete,
        update: @update
      )
    end
  end
end
