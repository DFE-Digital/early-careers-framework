# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQEhco < NPQ
      IDENTIFIERS = %w[
        npq-early-headship-coaching-offer
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default
        find_by(cohort: Cohort.find_by!(start_year: 2022), schedule_identifier: "npq-ehco-december")
      end

      def self.schedule_for(cohort: Cohort.current)
        return Finance::Schedule::NPQEhco.find_by!(cohort:) unless cohort_with_multiple_schedules?(cohort)

        case Date.current
        when Date.new(cohort.start_year, 9, 1)..Date.new(cohort.start_year, 11, -1)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-november")
        when Date.new(cohort.start_year, 12, 1)..Date.new(cohort.start_year + 1, 2, -1)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-december")
        when Date.new(cohort.start_year + 1, 3, 1)..Date.new(cohort.start_year + 1, 5, -1)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-march")
        when Date.new(cohort.start_year + 1, 6, 1)..Date.new(cohort.start_year + 1, 9, -1)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-june")
        else
          raise ArgumentError, "Invalid cohort for NPQEhco schedule"
        end
      end

      def self.cohort_with_multiple_schedules?(cohort)
        Cohort.where(start_year: 2022..).include?(cohort)
      end
    end
  end
end
