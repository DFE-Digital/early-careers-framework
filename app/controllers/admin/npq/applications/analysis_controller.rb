# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class AnalysisController < Admin::BaseController
        skip_after_action :verify_policy_scoped

        def invalid_payments_analysis
          authorize NPQApplication

          @applications = unaccepted_npq_applications_that_are_payable
        end

      private

        def unaccepted_npq_applications_that_are_payable
          NPQApplication.left_outer_joins(profile: [:participant_declarations])
                        .where.not(participant_profiles: { id: nil })
                        .where(lead_provider_approval_status: %w[pending rejected],
                               participant_profiles: {
                                 participant_declarations: { state: %w[paid payable] },
                               })
                        .uniq
        end
      end
    end
  end
end
