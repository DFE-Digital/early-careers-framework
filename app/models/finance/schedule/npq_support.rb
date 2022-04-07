# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQSupport < NPQ
      IDENTIFIERS = %w[
        npq-additional-support-offer
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default
        find_by(cohort: Cohort.current, schedule_identifier: "npq-aso-december")
      end
    end
  end
end
