# frozen_string_literal: true

module Incentives
  class UpdateSchoolParticipants < ::BaseService
    def call
      school.school_cohorts.each do |school_cohort|
        # "active" instead of "current" because we don't want to update participants
        # that have been claimed by another school
        school_cohort.active_induction_records.each do |induction_record|
          Incentives::UpdateParticipant.call(school_cohort:, participant_profile: induction_record.participant_profile)
        end
      end
    end

  private

    attr_reader :school

    def initialize(school:)
      @school = school
    end
  end
end
