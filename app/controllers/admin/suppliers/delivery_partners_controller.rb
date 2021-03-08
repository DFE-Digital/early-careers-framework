# frozen_string_literal: true

module Admin
  module Suppliers
    class DeliveryPartnersController < Admin::BaseController
      before_action :set_delivery_partner, only: %i[show delete edit destroy]
      skip_after_action :verify_policy_scoped

      # region create
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
            provider_relationship_hashes: @delivery_partner_form.provider_relationship_hashes,
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

      # endregion

      def show
        authorize @delivery_partner
      end

      def delete
        authorize @delivery_partner, :destroy?
      end

      def edit
        authorize @delivery_partner

        @delivery_partner_form = DeliveryPartnerForm.new(
          name: @delivery_partner.name,
          lead_providers: @delivery_partner.lead_providers.map(&:id),
          provider_relationship_hashes: @delivery_partner.provider_relationships.map do |relationship|
            DeliveryPartnerForm.provider_relationship_value(relationship.lead_provider, relationship.cohort)
          end,
        )
      end

      def destroy
        authorize @delivery_partner

        @delivery_partner.discard!
        redirect_to admin_suppliers_path
      end

    private

      def set_delivery_partner
        @delivery_partner = DeliveryPartner.find(params[:id])
      end
    end
  end
end
