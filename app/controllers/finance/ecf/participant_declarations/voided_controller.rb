# frozen_string_literal: true

module Finance
  module ECF
    module ParticipantDeclarations
      class VoidedController < BaseController
        before_action :set_statement

        def show
          @title = "Voided declarations"
          @voided_declarations = @statement.participant_declarations.voided
        end

        def ect
          @title = "ECT voided declarations"
          @voided_declarations = @statement.participant_declarations.ect.voided
          render action: :show
        end

        def mentor
          @title = "Mentor voided declarations"
          @voided_declarations = @statement.participant_declarations.mentor.voided
          render action: :show
        end

      private

        def set_statement
          @ecf_lead_provider = LeadProvider.find(params[:payment_breakdown_id])
          @cpd_lead_provider = @ecf_lead_provider.cpd_lead_provider
          @statement = @ecf_lead_provider.statements.find(params[:statement_id])
        end
      end
    end
  end
end
