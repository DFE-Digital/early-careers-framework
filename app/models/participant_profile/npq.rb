# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class NPQ < ParticipantProfile
    self.ignored_columns = %i[mentor_profile_id school_cohort_id start_term]
    belongs_to :school, optional: true
    belongs_to :npq_course, optional: true

    has_one :npq_application, foreign_key: :id

    after_commit :push_profile_to_big_query

    self.validation_steps = %i[identity decision].freeze

    def npq?
      true
    end

    def ecf?
      false
    end

    def approved?
      validation_decision(:decision).approved?
    end

    def rejected?
      decision = validation_decision(:decision)
      decision.persisted? && !decision.approved?
    end

    def participant_type
      :npq
    end

    def fundable?
      npq_application&.eligible_for_dfe_funding
    end

    def schedule_for(*)
      schedule
    end

  private

    def push_profile_to_big_query
      ::NPQ::StreamBigQueryProfileJob.perform_later(profile_id: id)
    end
  end
end
