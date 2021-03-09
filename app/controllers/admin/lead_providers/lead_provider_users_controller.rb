# frozen_string_literal: true

module Admin
  module LeadProviders
    class LeadProviderUsersController < Admin::BaseController
      skip_after_action :verify_policy_scoped
      before_action :load_lead_provider_user

      def edit; end

      def update
        if @lead_provider_user.update(permitted_attributes(@lead_provider_user))
          redirect_to :admin_supplier_users, notice: "Changes saved successfully"
        else
          render :edit
        end
      end

    private

      def load_lead_provider_user
        @lead_provider_user = User.find(params[:id])
        authorize @lead_provider_user
      end
    end
  end
end
