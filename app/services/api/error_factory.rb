# frozen_string_literal: true

module Api
  class ErrorFactory
    attr_reader :error

    def initialize(error:)
      @error = error
    end

    def call
      error.errors.map do |e|
        {
          title: "#{e.attribute.to_s.humanize} is #{e.type.to_s.humanize.downcase}",
          detail: e.message,
        }
      end
    end
  end
end
