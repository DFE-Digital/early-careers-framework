# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class Cohort < BaseComponent
        attr_reader :partnerships, :school

        def initialize(school:, cohort:, school_cohort:, partnerships: [])
          @school = school
          @cohort = cohort
          @school_cohort = school_cohort
          @partnerships = partnerships
        end

      private

        attr_reader :cohort, :school_cohort

        def cohort_info(&block)
          case school_cohort&.induction_programme_choice
          when "core_induction_programme" then CipInfo.new(school:, school_cohort:, &block)
          when "full_induction_programme" then FipInfo.new(school_cohort:, &block)
          else OtherInfo.new(school:, school_cohort:, cohort:, &block)
          end
        end
      end
    end
  end
end
