# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQEhco < NPQ
      IDENTIFIERS = %w[
        npq-early-headship-coaching-offer
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default_for(cohort: Cohort.current)
        find_by!(cohort:, schedule_identifier: "npq-ehco-june")
      end

      def self.schedule_for(cohort: Cohort.current)
        return Finance::Schedule::NPQEhco.find_by!(cohort:) unless cohort_with_multiple_schedules?(cohort)

        case Date.current
        when first_day_of_september_current_year(cohort.start_year)..last_day_of_november_current_year(cohort.start_year)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-november")
        when first_day_of_december_current_year(cohort.start_year)..last_day_of_february_next_year(cohort.start_year)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-december")
        when first_day_of_march_next_year(cohort.start_year)..last_day_of_may_next_year(cohort.start_year)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-march")
        when first_day_of_june_next_year(cohort.start_year)..last_day_of_september_next_year(cohort.start_year)
          Finance::Schedule::NPQEhco.find_by!(cohort:, schedule_identifier: "npq-ehco-june")
        else
          default_for(cohort:)
        end
      end

      def self.cohort_with_multiple_schedules?(cohort)
        Cohort.where(start_year: 2022..).include?(cohort)
      end

      def self.first_day_of_september_current_year(cohort_start_year)
        Date.new(cohort_start_year, 9, 1)
      end

      def self.last_day_of_november_current_year(cohort_start_year)
        Date.new(cohort_start_year, 11, -1)
      end

      def self.first_day_of_december_current_year(cohort_start_year)
        Date.new(cohort_start_year, 12, 1)
      end

      def self.last_day_of_february_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 2, -1)
      end

      def self.first_day_of_march_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 3, 1)
      end

      def self.last_day_of_may_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 5, -1)
      end

      def self.first_day_of_june_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 6, 1)
      end

      def self.last_day_of_september_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 9, -1)
      end
    end
  end
end
