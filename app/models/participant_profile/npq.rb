# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class NPQ < ParticipantProfile
    self.ignored_columns = %i[mentor_profile_id school_cohort_id start_term]
    belongs_to :school, optional: true
    belongs_to :npq_course, optional: true

    has_one :npq_application, foreign_key: :id, dependent: :destroy

    self.validation_steps = %i[identity decision].freeze

    def npq?
      true
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
      npq_application&.eligible_for_funding
    end
  end
end
