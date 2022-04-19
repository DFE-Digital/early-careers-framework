# frozen_string_literal: true

module Finance
  module ECF
    module ParticipantDeclarations
      class VoidedController < BaseController
        def show
          @ecf_lead_provider = LeadProvider.find(params[:payment_breakdown_id])
          @cpd_lead_provider = @ecf_lead_provider.cpd_lead_provider
          @statement = @cpd_lead_provider.statements.find_by(name: statement_id_to_name)
          @voided_declarations = ParticipantDeclaration.where(statement: @statement).voided
        end

      private

        def statement_id_to_name
          params[:statement_id].humanize.gsub("-", " ")
        end
      end
    end
  end
end
