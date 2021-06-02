# frozen_string_literal: true

module Dqt
  class Configuration
    class Client
      attr_accessor :headers, :host, :params, :port

      def initialize
        self.headers = {}
        self.host = nil
        self.params = {}
      end
    end

    def client
      @client ||= Client.new
    end
  end
end
