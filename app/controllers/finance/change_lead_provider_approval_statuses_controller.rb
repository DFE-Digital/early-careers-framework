# frozen_string_literal: true

module Finance
  class ChangeLeadProviderApprovalStatusesController < BaseController
    before_action :set_npq_application

    def new
      @change_lead_provider_approval_status_form = Finance::ChangeLeadProviderApprovalStatusForm.new
    end

    def create
      @change_lead_provider_approval_status_form = Finance::ChangeLeadProviderApprovalStatusForm.new(change_lead_provider_approval_status_form_params)
      @change_lead_provider_approval_status_form.npq_application = @npq_application

      if @change_lead_provider_approval_status_form.save
        redirect_to finance_participant_path(@npq_application.user)
      else
        render :new
      end
    end

  private

    def set_npq_application
      @npq_application = NPQApplication.find(params[:npq_application_id])
    end

    def change_lead_provider_approval_status_form_params
      return {} unless params.key?(:finance_change_lead_provider_approval_status_form)

      params.require(:finance_change_lead_provider_approval_status_form).permit(
        :change_status_to_pending,
      )
    end
  end
end
