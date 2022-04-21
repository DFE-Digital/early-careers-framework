# frozen_string_literal: true

module Finance
  module ECF
    module ParticipantDeclarations
      class VoidedController < BaseController
        def show
          @ecf_lead_provider = LeadProvider.find(params[:payment_breakdown_id])
          @cpd_lead_provider = @ecf_lead_provider.cpd_lead_provider
          @statement = @cpd_lead_provider.statements.find_by_humanised_name(params[:statement_id])
          @voided_declarations = @statement.voided_participant_declarations
        end
      end
    end
  end
end
