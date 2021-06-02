# frozen_string_literal: true

module Dqt
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end

require_relative "dqt/api"
require_relative "dqt/api/v1"
require_relative "dqt/api/v1/dqt_record"
require_relative "dqt/client"
require_relative "dqt/client/response"
require_relative "dqt/client/response_error"
require_relative "dqt/configuration"
