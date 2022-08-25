# frozen_string_literal: true

module Finance
  module NPQ
    module ParticipantDeclarations
      class VoidedController < BaseController
        def show
          @npq_lead_provider   = lead_provider_scope.find(params[:lead_provider_id])
          @cpd_lead_provider   = @npq_lead_provider.cpd_lead_provider
          @statement           = @cpd_lead_provider.npq_lead_provider.statements.find_by_humanised_name(params[:statement_id])
          @voided_declarations = @statement.participant_declarations.voided
        end

      private

        def lead_provider_scope
          policy_scope(NPQLeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
        end
      end
    end
  end
end
