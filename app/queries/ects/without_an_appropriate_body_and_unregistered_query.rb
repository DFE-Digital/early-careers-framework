# frozen_string_literal: true

module Ects
  class WithoutAnAppropriateBodyAndUnregisteredQuery < BaseService
    def call
      InductionRecord
        .active
        .training_status_active
        .joins(:participant_profile)
        .merge(ParticipantProfile::ECT.awaiting_induction_registration)
        .joins(induction_programme: :school_cohort)
        .where(induction_programme: { training_programme: training_programme_types })
        .where(appropriate_body_id: nil)
        .where(school_cohort: { appropriate_body_id: nil })
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
