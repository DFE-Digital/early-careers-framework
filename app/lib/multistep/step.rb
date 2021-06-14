# frozen_string_literal: true

module Multistep
  class Step
    def initialize(attributes:, next_step: nil)
      @attributes = attributes
      @next_step = next_step
    end

    attr_reader :attributes

    def next_step(form)
      return if @next_step.blank?
      return @next_step unless @next_step.respond_to? :call

      form.instance_exec(&@next_step)
    end
  end
end
