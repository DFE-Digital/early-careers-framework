# frozen_string_literal: true

module Admin
  class RecordsAnalysisController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @invalid_payments_analysis_count = invalid_payments_analysis.count
      @badly_formed_timeline_count = badly_formed_timeline.count
    end

    def invalid_payments_analysis
      @invalid_payments_analysis ||= unaccepted_npq_applications_that_are_payable
    end

    def badly_formed_timeline
      @badly_formed_timeline ||= induction_records_with_backwards_dates
    end

  private

    def induction_records_with_backwards_dates
      policy_scope(ParticipantProfile)
        .left_outer_joins(:induction_records)
        .where("induction_records.end_date < induction_records.start_date")
        .distinct
    end

    def unaccepted_npq_applications_that_are_payable
      policy_scope(NPQApplication)
        .left_outer_joins(profile: [:participant_declarations])
        .where.not(participant_profiles: { id: nil })
        .where(lead_provider_approval_status: %w[pending rejected],
               participant_profiles: {
                 participant_declarations: { state: %w[paid payable] },
               })
        .distinct
    end
  end
end
