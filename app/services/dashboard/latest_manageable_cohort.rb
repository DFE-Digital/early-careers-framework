# frozen_string_literal: true

module Dashboard
  class LatestManageableCohort < BaseService
    attr_reader :school

    def initialize(school)
      @school = school
    end

    def call
      pilot? ? Cohort.active_registration_cohort : Cohort.current
    end

  private

    def pilot?
      FeatureFlag.active?(:cohortless_dashboard, for: school)
    end
  end
end
