# frozen_string_literal: true

module Multistep
  class Step
    def initialize(attributes:, next_step: nil, multiple: false, before_complete: nil, update: false)
      @attributes = attributes
      @next_step = next_step
      @multiple = multiple
      @before_complete = before_complete
      @update = update
    end

    attr_reader :attributes

    def multiple?
      !!@multiple
    end

    def update?
      !!@update
    end

    def before_complete(form)
      return if @before_complete.blank?

      form.instance_exec(&@before_complete)
    end

    def next_step(form)
      return if @next_step.blank?
      return @next_step unless @next_step.respond_to? :call

      form.instance_exec(&@next_step)
    end
  end
end
