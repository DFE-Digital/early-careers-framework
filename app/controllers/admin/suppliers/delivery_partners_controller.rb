# frozen_string_literal: true

module Admin
  module Suppliers
    class DeliveryPartnersController < Admin::BaseController
      before_action :set_delivery_partner, only: %i[delete edit update destroy]
      before_action :load_new_delivery_partner, except: %i[choose_name delete edit update destroy]
      skip_after_action :verify_policy_scoped

      def choose_name
        unless params[:continue]
          session.delete(:delivery_partner_form)
        end
        load_new_delivery_partner
      end

      def receive_name
        render :choose_name and return unless @delivery_partner_form.valid?(:name)

        session[:delivery_partner_form] = @delivery_partner_form.serializable_hash
        redirect_to choose_lps_admin_delivery_partners_path
      end

      def choose_lead_providers; end

      def receive_lead_providers
        render :choose_lead_providers and return unless @delivery_partner_form.valid?(:lead_providers)

        session[:delivery_partner_form] = @delivery_partner_form.serializable_hash
        redirect_to choose_cohorts_admin_delivery_partners_path
      end

      def choose_cohorts; end

      def receive_cohorts
        render :choose_cohorts and return unless @delivery_partner_form.valid?(:cohorts)

        session[:delivery_partner_form] = @delivery_partner_form.serializable_hash
        redirect_to review_admin_delivery_partners_path
      end

      def review_delivery_partner; end

      def create_delivery_partner
        @delivery_partner_form.save!
        session.delete(:delivery_partner_form)

        set_success_message(heading: "Delivery partner created")
        redirect_to admin_suppliers_path
      end

      def edit
        @delivery_partner_form = DeliveryPartnerForm.from_delivery_partner(@delivery_partner)
      end

      def update
        @delivery_partner_form = DeliveryPartnerForm.new(delivery_partner_params)
        render :edit and return unless @delivery_partner_form.valid?(:update)

        @delivery_partner_form.save!(@delivery_partner)
        set_success_message(content: "Delivery partner updated", title: "Success")
        redirect_to admin_suppliers_path
      end

      def delete; end

      def destroy
        @delivery_partner.discard!
        set_success_message(content: "Delivery partner deleted", title: "Success")
        redirect_to admin_suppliers_path
      end

    private

      def set_delivery_partner
        @delivery_partner = DeliveryPartner.find(params[:id])
        authorize @delivery_partner
      end

      def load_new_delivery_partner
        authorize DeliveryPartner, :create?
        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        @delivery_partner_form.assign_attributes(delivery_partner_params)
      end

      def delivery_partner_params
        return {} unless params.key?(:delivery_partner_form)

        params.require(:delivery_partner_form).permit(:name, lead_provider_ids: [], provider_relationship_hashes: [])
      end
    end
  end
end
