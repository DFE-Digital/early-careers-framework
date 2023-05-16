# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class OtherInfo < BaseComponent
        attr_accessor :school

        def initialize(school:, cohort:, school_cohort:)
          @school = school
          @cohort = cohort
          @school_cohort = school_cohort
        end

      private

        attr_reader :school_cohort, :cohort

        MESSAGES = {
          design_our_own: "designing their own training",
          school_funded_fip: "school funded full induction programme",
          no_early_career_teachers: "no ECTs this year",
        }.freeze

        def message
          return "Not assigned" if school_cohort.nil?

          ["Not using service", MESSAGES[school_cohort.induction_programme_choice.to_sym]].compact.join(" - ")
        end
      end
    end
  end
end
