# frozen_string_literal: true

module Admin
  module RecordsAnalysis
    # noinspection RubyClassModuleNamingConvention
    class BadTimelinesQueryService < BaseService
      def call
        @policy_scope
          .left_outer_joins(:induction_records)
          .where("induction_records.end_date < induction_records.start_date")
          .distinct
      end

    private

      def initialize(policy_scope)
        @policy_scope = policy_scope
      end
    end
  end
end
