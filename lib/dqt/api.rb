# frozen_string_literal: true

module DQT
  class Api
    delegate :dqt_record, to: :v1

    def initialize(client:)
      self.client = client
      self.v1 = nil
    end

    def v1
      @v1 ||= V1.new(client:)
    end

  private

    attr_accessor :client
    attr_writer :v1
  end
end
