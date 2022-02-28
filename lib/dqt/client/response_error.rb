# frozen_string_literal: true

module DQT
  class Client::ResponseError < StandardError
    attr_accessor :response

    def initialize(msg = nil, response = nil)
      super(msg)
      self.response = response
    end
  end
end
