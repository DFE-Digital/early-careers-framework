# frozen_string_literal: true

module Incentives
  class UpdateParticipant < ::BaseService
    def call
      participant_profile.update!(pupil_premium_uplift: pupil_premium_uplift?,
                                  sparsity_uplift: sparsity_uplift?)
    end

  private

    attr_reader :school_cohort, :participant_profile

    def initialize(school_cohort:, participant_profile:)
      @school_cohort = school_cohort
      @participant_profile = participant_profile
    end

    def pupil_premium_uplift?
      school.pupil_premium_uplift?(start_year)
    end

    def sparsity_uplift?
      school.sparsity_uplift?(start_year)
    end

    def start_year
      @start_year ||= school_cohort.cohort.start_year
    end

    def school
      @school ||= school_cohort.school
    end
  end
end
