# frozen_string_literal: true

module Finance
  module NPQ
    class CoursePaymentBreakdownsController < BaseController
      def show
        @npq_lead_provider = lead_provider_scope.find(params[:lead_provider_id])
        @cpd_lead_provider = @npq_lead_provider.cpd_lead_provider
        @npq_course        = NPQCourse.find_by!(identifier: params[:id])
        @statement         = @cpd_lead_provider.npq_lead_provider.statements.find_by(name: statement_id_to_name)
      end

    private

      def statement_id_to_name
        params[:statement_id].humanize.gsub("-", " ")
      end

      def lead_provider_scope
        policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
      end
    end
  end
end
