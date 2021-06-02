# frozen_string_literal: true

# The contents of this file and ./dqt have mostly been copied from
# github.com/DFE-Digital/claim-additional-payments-for-teaching/tree/master/lib
# there is no independent library available at the moment of writing this

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
