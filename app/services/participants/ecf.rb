# frozen_string_literal: true

module Participants
  module ECF
    extend ActiveSupport::Concern

    included do
      delegate :early_career_teacher?, :mentor_profile, :early_career_teacher_profile, :participant?, to: :user, allow_nil: true
      delegate :school_cohort, :participant_profile_state, to: :user_profile, allow_nil: true
      delegate :lead_provider, to: :cpd_lead_provider
    end

    def matches_lead_provider?
      relevant_induction_record.present?
    end

    def relevant_induction_record
      @relevant_induction_record ||= InductionRecord
        .joins(:participant_profile, induction_programme: { school_cohort: [:cohort], partnership: [:lead_provider] })
        .where(participant_profile: user_profile)
        .where(induction_programme: { partnerships: { lead_provider: } })
        .where(induction_programme: { school_cohorts: { cohort: Cohort.where(start_year: 2021..) } })
        .order(start_date: :desc)
        .first
    end
  end
end
