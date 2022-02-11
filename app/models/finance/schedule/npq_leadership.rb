# frozen_string_literal: true

require "finance/schedule"

module Finance
  class Schedule < ApplicationRecord
    class NPQLeadership < Schedule
      IDENTIFIERS = %w[
        npq-senior-leadership
        npq-headship
        npq-executive-leadership
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default
        find_by(cohort: Cohort.current, schedule_identifier: "npq-leadership-spring")
      end
    end
  end
end
