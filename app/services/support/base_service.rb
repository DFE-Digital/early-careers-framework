# frozen_string_literal: true

module Support
  class BaseService
  private

    def log_message(message)
      logger.info(message)
    end

    def log_error(message, raise: false)
      logger.error(message)
      raise(message.to_s) if raise
    end

    def logger
      @logger = Logger.new(Rails.env.test? ? nil : $stdout)
    end
  end
end
