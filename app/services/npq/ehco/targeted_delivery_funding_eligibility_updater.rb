# frozen_string_literal: true

module NPQ
  module Ehco
    class TargetedDeliveryFundingEligibilityUpdater
      REOPEN_DATE = Time.zone.parse("6 June 2022 12:00")

      class << self
        delegate :run, to: :new
      end

      def run
        logger = Logger.new($stdout)
        logger.info "Updating EHCO NPQ Applications, this may take a couple of minutes..."

        ehco_npq_course = NPQCourse.find_by(identifier: "npq-early-headship-coaching-offer")

        arel_table = NPQApplication.arel_table
        npq_applications = ehco_npq_course.npq_applications
                                          .where(targeted_delivery_funding_eligibility: true)
                                          .where(arel_table[:created_at].gteq(REOPEN_DATE))

        updated_count = 0

        npq_applications.find_each do |npq_application|
          logger.info "Updating EHCO NPQ Application #{npq_application.id}"
          npq_application.update!(targeted_delivery_funding_eligibility: false)

          updated_count += 1
        rescue StandardError => e
          logger.error "Encountered errors while updating EHCO NPQ Application ID##{npq_application.id}: #{e.message}"
        end

        logger.info "Updated EHCO NPQ Application count: #{updated_count}"
      end
    end
  end
end
