# frozen_string_literal: true

require "tasks/valid_test_data_generator/base_populater"

module ValidTestDataGenerator
  class PendingNPQApplicationsPopulater < BasePopulater
    include ActiveSupport::Testing::TimeHelpers

    def populate
      return unless Rails.env.in?(%w[development review sandbox])

      logger.info "PendingNPQApplicationsPopulater: Started!"

      ActiveRecord::Base.transaction do
        create_applications!
      end

      logger.info "PendingApplicationsPopulater: Finished!"
    end
  end
end
