# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    class NPQSpecialist < NPQ
      IDENTIFIERS = %w[
        npq-leading-teaching
        npq-leading-behaviour-culture
        npq-leading-teaching-development
      ].freeze

      PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

      def self.default
        find_by(cohort: Cohort.current, schedule_identifier: "npq-specialist-spring")
      end
    end
  end
end
