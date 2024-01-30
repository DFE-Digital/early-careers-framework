# frozen_string_literal: true

module Ects
  class WithAnAppropriateBodyAndUnregisteredQuery < BaseService
    def call
      InductionRecord
        .active
        .training_status_active
        .joins(:participant_profile)
        .where(participant_profile: { induction_start_date: nil, type: "ParticipantProfile::ECT" })
        .joins(induction_programme: :school_cohort)
        .where(induction_programme: { training_programme: training_programme_types })
        .where("induction_records.appropriate_body_id IS NOT NULL OR school_cohorts.appropriate_body_id IS NOT NULL")
    end

  private

    attr_reader :include_fip, :include_cip

    def initialize(include_fip: true, include_cip: true)
      @include_fip = include_fip
      @include_cip = include_cip
    end

    def training_programme_types
      training_programmes = []
      training_programmes << "full_induction_programme" if include_fip
      training_programmes << "core_induction_programme" if include_cip
      training_programmes
    end
  end
end
