# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQSpecialist < NPQ
      IDENTIFIERS = %w[
        npq-leading-teaching
        npq-leading-behaviour-culture
        npq-leading-teaching-development
        npq-leading-literacy
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default_for(cohort: Cohort.current)
        find_by!(cohort:, schedule_identifier: "npq-specialist-spring")
      end

      def self.schedule_for(cohort: Cohort.current)
        return find_by!(cohort:) unless cohort_with_multiple_schedules?(cohort)

        case Date.current

        when june_1_current_year(cohort.start_year)..december_25_current_year(cohort.start_year)
          find_by!(cohort:, schedule_identifier: "npq-specialist-autumn")
        when december_26_current_year(cohort.start_year)..april_15_next_year(cohort.start_year)
          find_by!(cohort:, schedule_identifier: "npq-specialist-spring")
        when april_16_next_year(cohort.start_year)..december_25_next_year(cohort.start_year)
          find_by!(cohort:, schedule_identifier: "npq-specialist-autumn")
        when december_26_next_year(cohort.start_year)..april_15_next_next_year(cohort.start_year)
          find_by!(cohort:, schedule_identifier: "npq-specialist-spring")
        else
          default_for(cohort:)
        end
      end

      def self.cohort_with_multiple_schedules?(cohort)
        Cohort.where(start_year: 2022..).include?(cohort)
      end

      def self.june_1_current_year(cohort_start_year)
        Date.new(cohort_start_year, 6, 1)
      end

      def self.december_25_current_year(cohort_start_year)
        Date.new(cohort_start_year, 12, 25)
      end

      def self.december_26_current_year(cohort_start_year)
        Date.new(cohort_start_year, 12, 26)
      end

      def self.april_15_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 4, 15)
      end

      def self.april_16_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 4, 16)
      end

      def self.december_25_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 12, 25)
      end

      def self.december_26_next_year(cohort_start_year)
        Date.new(cohort_start_year + 1, 12, 26)
      end

      def self.april_15_next_next_year(cohort_start_year)
        Date.new(cohort_start_year + 2, 4, 15)
      end
    end
  end
end
