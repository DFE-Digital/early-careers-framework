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

    %i[validates validate validates_with].each do |validation_method|
      define_method validation_method do |*args, **options, &block|
        options[:on] = Array.wrap(options[:on]) << @step_name << :default
        @form_class.public_send(validation_method, *args, **options, &block)
      end
    end
  end
end
