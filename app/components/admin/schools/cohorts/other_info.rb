# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class OtherInfo < BaseComponent
        renders_one :summary_list_rows

        attr_accessor :school

        def initialize(school:, cohort:, school_cohort:)
          @school = school
          @cohort = cohort
          @school_cohort = school_cohort
        end

      private

        attr_reader :school_cohort, :cohort

        MESSAGES = {
          design_our_own: "Designing their own training",
          school_funded_fip: "School-funded full induction programme",
          no_early_career_teachers: "No ECTs this year",
        }.freeze

        def message
          return "Not assigned" if school_cohort.nil?
          return "Not using service" if school_cohort.induction_programme_choice.blank?

          MESSAGES[school_cohort.induction_programme_choice.to_sym]
        end
      end
    end
  end
end
