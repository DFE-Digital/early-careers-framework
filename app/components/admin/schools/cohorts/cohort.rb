# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class Cohort < BaseComponent
        attr_reader :partnerships

        def initialize(cohort:, school_cohort:, partnerships: [])
          @cohort = cohort
          @school_cohort = school_cohort
          @partnerships = partnerships
        end

      private

        attr_reader :cohort, :school_cohort

        def cohort_info
          case school_cohort&.induction_programme_choice
          when "core_induction_programme" then CipInfo.new(school_cohort:)
          when "full_induction_programme" then FipInfo.new(school_cohort:)
          else OtherInfo.new(school_cohort:, cohort:)
          end
        end
      end
    end
  end
end
