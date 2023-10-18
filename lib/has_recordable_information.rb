# frozen_string_literal: true

module HasRecordableInformation
  extend ActiveSupport::Concern

  included do
    def reset_recorded_info
      recorded_info.clear
    end

    def recorded_info
      @recorded_info ||= []
    end

    def record_info(info)
      recorded_info << info
      Rails.logger.info(info)
    end
  end
end
