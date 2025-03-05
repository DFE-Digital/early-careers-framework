# frozen_string_literal: true

module Finance
  module ECF
    module ParticipantDeclarations
      class VoidController < BaseController
        before_action :set_participant_profile_and_declaration

        def new; end

        def create
          VoidParticipantDeclaration.new(@declaration, voided_by_user: current_user).call
          set_success_message(**I18n.t("finance.void_declaration.success"))
        rescue Api::Errors::InvalidTransitionError
          set_important_message(**I18n.t("finance.void_declaration.failure"))
        ensure
          redirect_to finance_participant_path(@participant_profile.user)
        end

      private

        def set_participant_profile_and_declaration
          @participant_profile = ParticipantProfile.find(params[:participant_profile_id])
          @declaration = @participant_profile.participant_declarations.includes(:cpd_lead_provider).find(params[:participant_declaration_id])
        end
      end
    end
  end
end
