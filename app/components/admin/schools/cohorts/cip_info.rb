# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class CipInfo < BaseComponent
        def initialize(school_cohort:)
          @school_cohort = school_cohort
        end

      private

        attr_reader :school_cohort
      end
    end
  end
end
