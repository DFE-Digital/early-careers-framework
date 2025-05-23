# frozen_string_literal: true

module Admin
  module Suppliers
    class LeadProviderUsersController < Admin::BaseController
      skip_after_action :verify_policy_scoped
      before_action :load_lead_provider_user

      def edit; end

      def update
        if @lead_provider_user.update(permitted_attributes(@lead_provider_user))
          set_success_message(content: "Changes saved successfully", title: "Success")
          redirect_to :admin_supplier_users
        else
          render :edit
        end
      end

      def delete
        authorize @lead_provider_user
      end

      def destroy
        authorize @lead_provider_user
        @lead_provider_user.destroy!
        set_success_message(content: "User deleted", title: "Success")
        redirect_to admin_supplier_users_path
      end

    private

      def load_lead_provider_user
        @lead_provider_user = User.find(params[:id])
        authorize @lead_provider_user
      end
    end
  end
end
