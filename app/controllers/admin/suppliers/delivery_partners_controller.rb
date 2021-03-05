# frozen_string_literal: true

module Admin
  module Suppliers
    class DeliveryPartnersController < Admin::BaseController
      skip_after_action :verify_policy_scoped

      def choose_lead_providers
        authorize DeliveryPartner, :create?

        new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
        session[:delivery_partner_form] = (session[:delivery_partner_form] || {}).merge({ name: new_supplier_form.name })
        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
      end

      def receive_lead_providers
        authorize DeliveryPartner, :create?

        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        @delivery_partner_form.populate_provider_relationships(params)

        render :choose_lead_providers and return unless @delivery_partner_form.valid?

        session[:delivery_partner_form].merge!(
          {
            lead_providers: @delivery_partner_form.lead_providers,
            provider_relationships: @delivery_partner_form.provider_relationships,
          },
        )
        redirect_to review_admin_delivery_partners_path
      end

      def review_delivery_partner
        authorize DeliveryPartner, :create?
        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
      end

      def create_delivery_partner
        authorize DeliveryPartner, :create?

        delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        delivery_partner = delivery_partner_form.save!

        redirect_to success_admin_delivery_partners_path(delivery_partner: delivery_partner)
      end

      def delivery_partner_success
        authorize DeliveryPartner, :create?
        session.delete(:new_supplier_form)
        session.delete(:lead_provider_form)
        session.delete(:delivery_partner_form)

        @delivery_partner = DeliveryPartner.find(params[:delivery_partner])
      end

      def show
        @delivery_partner = DeliveryPartner.find(params[:id])
        authorize @delivery_partner
      end

      def delete
        @delivery_partner = DeliveryPartner.find(params[:id])
        authorize @delivery_partner, :destroy?
      end

      # def destroy
      #
      # end
    end
  end
end
