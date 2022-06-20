# frozen_string_literal: true

module Admin
  module DeliveryPartners
    class UsersController < Admin::BaseController
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped
      before_action :set_user, only: %i[edit update delete destroy]

      def index
        sorted_users = User.delivery_partner_users.name_order
        @pagy, @users = pagy(sorted_users, page: params[:page], items: 20)
      end

      def new
        @delivery_partners_user_form = ::DeliveryPartners::CreateUserForm.new
      end

      def create
        @delivery_partners_user_form = ::DeliveryPartners::CreateUserForm.new(permitted_params)

        if @delivery_partners_user_form.save
          set_success_message(content: "Delivery partner user successfully added.", title: "Success")
          redirect_to admin_delivery_partners_users_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @delivery_partners_user_form = ::DeliveryPartners::UpdateUserForm.new(@user)
      end

      def update
        @delivery_partners_user_form = ::DeliveryPartners::UpdateUserForm.new(@user)

        if @delivery_partners_user_form.update(permitted_params)
          set_success_message(content: "Changes saved successfully.", title: "Success")
          redirect_to admin_delivery_partners_users_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def delete; end

      def destroy
        @user.delivery_partner_profile.destroy!
        set_success_message(content: "Delivery partner user deleted.", title: "Success")
        redirect_to admin_delivery_partners_users_path
      end

    private

      def permitted_params
        params.require(:delivery_partners_user_form).permit(
          :delivery_partner_id,
          :full_name,
          :email,
        )
      end

      def set_user
        @user = User.delivery_partner_users.find(params[:id])
        authorize @user
      end
    end
  end
end
