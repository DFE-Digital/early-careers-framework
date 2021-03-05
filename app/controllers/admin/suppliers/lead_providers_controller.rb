# frozen_string_literal: true

module Admin
  module Suppliers
    class LeadProvidersController < Admin::BaseController
      before_action :show, only: %i[show_schools show_users show_details show_dps]

      skip_after_action :verify_policy_scoped

      def choose_cip
        authorize LeadProvider, :create?

        new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
        session[:lead_provider_form] = (session[:lead_provider_form] || {}).merge({ name: new_supplier_form.name })
        @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
      end

      def receive_cip
        authorize LeadProvider, :create?

        @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
        @lead_provider_form.cip = params.dig(:lead_provider_form, :cip)

        unless @lead_provider_form.valid?(:cip)
          render :choose_cip and return
        end

        session[:lead_provider_form].merge!({ cip: @lead_provider_form.cip })
        redirect_to choose_cohorts_admin_lead_providers_path
      end

      def choose_cohorts
        authorize LeadProvider, :create?
        @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
      end

      def receive_cohorts
        authorize LeadProvider, :create?

        @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
        @lead_provider_form.cohorts = params.dig(:lead_provider_form, :cohorts)&.keep_if(&:present?)

        unless @lead_provider_form.valid?(:cohorts)
          render :choose_cohorts and return
        end

        session[:lead_provider_form].merge!({ cohorts: @lead_provider_form.cohorts })
        redirect_to review_admin_lead_providers_path
      end

      def review
        authorize LeadProvider, :create?

        @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
      end

      def create
        authorize LeadProvider, :create?

        lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
        lead_provider = lead_provider_form.save!

        redirect_to success_admin_lead_providers_path(lead_provider: lead_provider)
      end

      def success
        authorize LeadProvider, :create?
        session.delete(:new_supplier_form)
        session.delete(:lead_provider_form)
        session.delete(:delivery_partner_form)

        @lead_provider = LeadProvider.find(params[:lead_provider])
      end

      def edit
        @lead_provider = LeadProvider.find(params[:lead_provider])
        @lead_provider_form = LeadProviderForm.new(
          name: @lead_provider.name,
          cip: @lead_provider.cips.first.id,
          cohorts: @lead_provider.cohorts,
        )
        authorize @lead_provider, :edit?
      end

      def show_details; end

      def show_users; end

      def show_dps; end

      def show_schools; end

    private

      def show
        @lead_provider = LeadProvider.find(params[:lead_provider])
        authorize @lead_provider, :show?
      end
    end
  end
end
