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
    end
  end
end
