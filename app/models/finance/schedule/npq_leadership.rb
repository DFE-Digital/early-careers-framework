# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQLeadership < NPQ
      IDENTIFIERS = %w[
        npq-senior-leadership
        npq-headship
        npq-executive-leadership
        npq-early-years-leadership
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default
        find_by(cohort: Cohort.current, schedule_identifier: "npq-leadership-spring")
      end
    end
  end
end
