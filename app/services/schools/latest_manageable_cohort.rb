# frozen_string_literal: true

module Schools
  class LatestManageableCohort < ::BaseService
    def call
      if Cohort.within_next_registration_period? && school_in_pilot?
        Cohort.active_registration_cohort
      else
        Cohort.current
      end
    end

  private
    
    attr_reader :school

    def initialize(school:)
      @school = school
    end

    def school_in_pilot?
      FeatureFlag.active?(:registration_pilot, for: school)
    end
  end
end
