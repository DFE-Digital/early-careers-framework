# frozen_string_literal: true

module Support
  class BaseService
  private

    def log_message(message)
      logger.info(message)
    end

    def log_error(message)
      logger.error(message)
    end

    def logger
      @logger = Logger.new($stdout)
    end
  end
end
