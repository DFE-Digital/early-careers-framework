# frozen_string_literal: true

module Admin
  module DeliveryPartners
    class UsersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index
      skip_after_action :verify_policy_scoped, except: :index
      before_action :set_delivery_partner_profile_and_authorize, only: %i[edit update delete destroy]

      def index
        @query = params[:query]
        authorize DeliveryPartnerProfile
        @pagy, @delivery_partner_profiles = pagy(scoped, page: params[:page], items: 20)
      end

      def new
        authorize DeliveryPartnerProfile
        @delivery_partners_user_form = ::DeliveryPartners::CreateUserForm.new
      end

      def create
        authorize DeliveryPartnerProfile
        @delivery_partners_user_form = ::DeliveryPartners::CreateUserForm.new(permitted_params)

        if @delivery_partners_user_form.save
          set_success_message(content: "Delivery partner user successfully added.", title: "Success")
          redirect_to admin_delivery_partners_users_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @delivery_partners_user_form = ::DeliveryPartners::UpdateUserForm.new(delivery_partner_profile: @delivery_partner_profile)
      end

      def update
        @delivery_partners_user_form = ::DeliveryPartners::UpdateUserForm.new(delivery_partner_profile: @delivery_partner_profile)

        if @delivery_partners_user_form.update(permitted_params)
          set_success_message(content: "Changes saved successfully.", title: "Success")
          redirect_to admin_delivery_partners_users_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def delete; end

      def destroy
        @delivery_partner_profile.destroy!
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

      def set_delivery_partner_profile_and_authorize
        @delivery_partner_profile = DeliveryPartnerProfile.find(params[:id])
        authorize @delivery_partner_profile.user
      end

      def scoped
        return policy_scope(DeliveryPartnerProfile).includes(:user).order("users.full_name asc") if params[:query].blank?

        ::DeliveryPartnerProfiles::SearchQuery
          .new(query: params[:query], scope: policy_scope(DeliveryPartnerProfile))
          .call
      end
    end
  end
end
