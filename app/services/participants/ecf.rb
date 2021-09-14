# frozen_string_literal: true

module Participants
  module ECF
    extend ActiveSupport::Concern

    included do
      delegate :early_career_teacher?, :mentor_profile, :early_career_teacher_profile, :participant?, to: :user, allow_nil: true
      delegate :school_cohort, :participant_profile_state, :participant_profile_states, :validate_participant_state, to: :user_profile, allow_nil: true
    end

    def matches_lead_provider?
      cpd_lead_provider == school_cohort&.lead_provider&.cpd_lead_provider
    end
  end
end
