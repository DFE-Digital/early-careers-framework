# frozen_string_literal: true

module ValidTestDataGenerators
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
