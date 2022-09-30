# frozen_string_literal: true

module Admin
  class DeliveryPartnerProfilesController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @pagy, @delivery_partner_profiles = pagy(DeliveryPartnerProfile.includes(:user), page: params[:page], items: 20)
    end

    def show
      authorize delivery_partner_profile.user
    end

    def new
      @delivery_partner_profile = DeliveryPartnerProfile.new
      @delivery_partner_profile.build_user
      @delivery_partner_profile.build_delivery_partner
    end

    def create
      @delivery_partner_profile = DeliveryPartnerProfile.new(permitted_params)

      if @delivery_partner_profile.save
        set_success_message(content: "Delivery partner user successfully added.", title: "Success")
        redirect_to admin_delivery_partner_profiles_path
      else
        @delivery_partner_profile.errors.delete(:delivery_partner)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize delivery_partner_profile.user
    end

    def update
      authorize delivery_partner_profile.user

      delivery_partner_profile.assign_attributes(permitted_params)

      return render :edit, status: :unprocessable_entity unless delivery_partner_profile.save

      set_success_message(content: "Changes saved successfully.", title: "Success")
      redirect_to admin_delivery_partner_profiles_path
    end

    def delete
      delivery_partner_profile
    end

    def destroy
      authorize delivery_partner_profile.user

      delivery_partner_profile.destroy!
      set_success_message(content: "Delivery partner user deleted.", title: "Success")
      redirect_to admin_delivery_partner_profiles_path
    end

  private

    def permitted_params
      params.require(:delivery_partner_profile).permit(
        :delivery_partner_id,
        user_attributes: %i[
          full_name
          email
        ],
      )
    end

    def delivery_partner_profile
      @delivery_partner_profile ||= DeliveryPartnerProfile.find(params[:id])
    end
  end
end
