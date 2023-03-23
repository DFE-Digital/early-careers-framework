# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeLeadProvidersController < BaseController
      def new
        change_lead_provider_form
      end

      def create
        change_lead_provider_form.assign_attributes(change_lead_provider_form_params)

        if change_lead_provider_form.valid?
          render :confirm
        else
          render :new
        end
      end

      def update
        change_lead_provider_form.assign_attributes(change_lead_provider_form_params)

        if change_lead_provider_form.save
          set_success_message(
            heading: "New lead provider assigned",
            content: "<p class=\"govuk-body\"> The new lead provider has been successfully assigned to this participant.</p>".html_safe,
          )
          redirect_to finance_participant_path(participant_profile.user)
        else
          render :new
        end
      end

    private

      def participant_profile
        @participant_profile ||= ParticipantProfile::NPQ.find(params[:participant_profile_id])
      end

      def change_lead_provider_form_params
        params.fetch(:finance_npq_change_lead_provider_form, {}).permit(
          :lead_provider_id,
        )
      end

      def change_lead_provider_form
        @change_lead_provider_form ||= Finance::NPQ::ChangeLeadProviderForm.new(participant_profile:)
      end
    end
  end
end
