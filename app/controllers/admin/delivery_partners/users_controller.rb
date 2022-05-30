# frozen_string_literal: true

module Admin
  module DeliveryPartners
    class UsersController < Admin::BaseController
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def index
        sorted_users = User.delivery_partner_users.name_order
        @pagy, @users = pagy(sorted_users, page: params[:page], items: 20)
      end

      def new
        @delivery_partners_user_form = ::DeliveryPartners::UserForm.new
      end

      def create
        @delivery_partners_user_form = ::DeliveryPartners::UserForm.new(permitted_params)

        if @delivery_partners_user_form.save
          redirect_to action: :index, notice: "Delivery partner user successfully added."
        else
          render :new, status: :unprocessable_entity
        end
      end

    private

      def permitted_params
        params.require(:delivery_partners_user_form).permit(
          :delivery_partner_id,
          :full_name,
          :email,
        )
      end
    end
  end
end
