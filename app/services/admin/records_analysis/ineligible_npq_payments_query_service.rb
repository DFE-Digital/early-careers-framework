# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    # noinspection RubyClassModuleNamingConvention
    class IneligibleNPQPaymentsQueryService < BaseService
      def call
        @policy_scope
          .left_outer_joins(profile: [:participant_declarations])
          .where.not(participant_profiles: { id: nil })
          .where(lead_provider_approval_status: %w[pending rejected],
                 participant_profiles: {
                   participant_declarations: { state: %w[paid payable] },
                 })
          .distinct
      end

    private

      def initialize(policy_scope)
        @policy_scope = policy_scope
      end
    end
  end
end
