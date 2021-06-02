# frozen_string_literal: true

require_relative "v1/dqt_record"

module Dqt
  class Api
    class V1
      def initialize(client:)
        self.client = client
      end

      def dqt_record
        @dqt_record ||= DQTRecord.new(client: client)
      end

    private

      attr_accessor :client
    end
  end
end
