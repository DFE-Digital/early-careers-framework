# frozen_string_literal: true

module Admin
  class RecordsAnalysisController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @invalid_payment_counts = invalid_payments.count
      @bad_timeline_counts = bad_timelines.count
    end

    def show
      case params[:id]
      when "invalid-payments"
        @npq_applications = invalid_payments
      when "bad-timelines"
        @participant_profiles = bad_timelines
      else
        return redirect_to admin_records_analysis_path
      end

      render params[:id].humanize.underscore
    end

  private

    def invalid_payments
      Admin::RecordsAnalysis::IneligibleNPQPaymentsQueryService.call(policy_scope(NPQApplication))
    end

    def bad_timelines
      Admin::RecordsAnalysis::BadTimelinesQueryService.call(policy_scope(ParticipantProfile::ECF))
    end
  end
end
