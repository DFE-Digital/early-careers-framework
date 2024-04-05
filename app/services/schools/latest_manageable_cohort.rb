# frozen_string_literal: true

module Schools
  class LatestManageableCohort < ::BaseService
    def call
      if active_registration_pilot?
        if school_in_pilot?
          Cohort.active_registration_cohort
        else
          Cohort.current
        end
      else
        Cohort.active_registration_cohort
      end
    end

  private

    attr_reader :school

    def initialize(school:)
      @school = school
    end

    def active_registration_pilot?
      FeatureFlag.active?(:registration_pilot)
    end

    def school_in_pilot?
      FeatureFlag.active?(:registration_pilot_school, for: school)
    end
  end
end
