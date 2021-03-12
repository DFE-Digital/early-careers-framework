# frozen_string_literal: true

module Admin
  module Suppliers
    class DeliveryPartnersController < Admin::BaseController
      before_action :set_delivery_partner, only: %i[show delete edit update destroy]
      skip_after_action :verify_policy_scoped

      def choose_name
        authorize DeliveryPartner, :new?

        if params[:continue]
          @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        else
          session.delete(:delivery_partner_form)
          @delivery_partner_form = DeliveryPartnerForm.new
        end
      end

      def receive_name
        authorize DeliveryPartner, :new?
        @delivery_partner_form = DeliveryPartnerForm.new(params.require(:delivery_partner_form).permit(:name))

        render :choose_name and return unless @delivery_partner_form.valid?(:name)

        session[:delivery_partner_form] = (session[:delivery_partner_form] || {}).merge({ name: @delivery_partner_form.name })
        redirect_to choose_lps_admin_delivery_partners_path
      end

      def choose_lead_providers
        authorize DeliveryPartner, :create?

        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
      end

      def receive_lead_providers
        authorize DeliveryPartner, :create?

        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        @delivery_partner_form.populate_provider_relationships(params)

        render :choose_lead_providers and return unless @delivery_partner_form.valid?(:lead_providers)

        session[:delivery_partner_form].merge!(
          {
            lead_provider_ids: @delivery_partner_form.lead_provider_ids,
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
        delivery_partner_form.save!
        session.delete(:delivery_partner_form)

        set_success_message(heading: "Delivery partner created")
        redirect_to admin_suppliers_path
      end

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
          lead_provider_ids: @delivery_partner.lead_providers.map(&:id),
          provider_relationship_hashes: @delivery_partner.provider_relationships.map do |relationship|
            DeliveryPartnerForm.provider_relationship_value(relationship.lead_provider, relationship.cohort)
          end,
        )
      end

      def update
        authorize @delivery_partner

        @delivery_partner_form = DeliveryPartnerForm.new(params.require(:delivery_partner_form).permit(:name))
        @delivery_partner_form.populate_provider_relationships(params)

        render :edit and return unless @delivery_partner_form.valid?

        @delivery_partner_form.update!(@delivery_partner)
        redirect_to admin_delivery_partner_path(@delivery_partner)
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
