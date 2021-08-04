# frozen_string_literal: true

module Api
  class ErrorFactory
    attr_reader :model

    def initialize(model:)
      @model = model
    end

    def call
      model.errors.map do |e|
        {
          title: "#{model.class.human_attribute_name(e.attribute)} is #{e.type.to_s.humanize.downcase}",
          detail: e.message,
        }
      end
    end
  end
end
