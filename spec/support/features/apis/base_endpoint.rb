# frozen_string_literal: true

module APIs
  class BaseEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    attr_reader :token, :response

    def initialize(*tokens)
      @token = tokens[0]
    end

    def self.load(*tokens)
      new(tokens[0])
    end
  end
end
