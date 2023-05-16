# frozen_string_literal: true

module Dashboard
  class LatestManageableCohort < BaseService
    attr_reader :school

    def initialize(school)
      @school = school
    end

    def call
      [
        Cohort.latest,
        pilot? ? Cohort.active_registration_cohort : Cohort.current,
      ].compact.min_by(&:start_year)
    end

  private

    def pilot?
      FeatureFlag.active?(:cohortless_dashboard, for: school)
    end
  end
end
