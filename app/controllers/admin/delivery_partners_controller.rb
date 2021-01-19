# frozen_string_literal: true

class Admin::DeliveryPartnersController < Admin::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def choose_lead_providers
    authorize DeliveryPartner, :create?

    new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
    if session[:delivery_partner_form].nil?
      session[:delivery_partner_form] = { name: new_supplier_form.name }
    else
      session[:delivery_partner_form].merge!({ name: new_supplier_form.name })
    end

    @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
  end

  def receive_lead_providers
    authorize DeliveryPartner, :create?

    provider_relationships = []
    # Ensure all selected lead providers have at least one selected cohort
    chosen_lead_providers = params.dig(:delivery_partner_form, :lead_providers)&.keep_if(&:present?)

    unless chosen_lead_providers&.any?
      @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
      @delivery_partner_form.errors.add(:lead_providers, :blank, message: "Choose at least one")
      render :choose_lead_providers and return
    end

    chosen_lead_providers.each do |lead_provider|
      chosen_cohorts = params.dig(
        :delivery_partner_form,
        lead_provider.to_sym,
        :cohorts,
      )&.keep_if(&:present?)

      unless chosen_cohorts&.any?
        @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
        @delivery_partner_form.errors.add(:lead_providers, :blank, message: "Choose at least one cohort for every selected lead provider")
        # rubocop:disable Lint/NonLocalExitFromIterator
        render :choose_lead_providers and return
        # rubocop:enable Lint/NonLocalExitFromIterator
      end

      chosen_cohorts.each do |cohort|
        provider_relationships.push ProviderRelationship.new(
          cohort: Cohort.find(cohort),
          lead_provider: LeadProvider.find(lead_provider),
        )
      end
    end

    delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
    delivery_partner_form.provider_relationships = provider_relationships
    session[:delivery_partner_form] = delivery_partner_form
    redirect_to admin_new_delivery_partner_review_path
  end

  def review_delivery_partner
    authorize DeliveryPartner, :create?
    @delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
  end

  def create_delivery_partner
    authorize DeliveryPartner, :create?

    delivery_partner_form = DeliveryPartnerForm.new(session[:delivery_partner_form])
    delivery_partner = DeliveryPartner.new(name: delivery_partner_form.name)

    ActiveRecord::Base.transaction do
      delivery_partner.save!
      delivery_partner_form.chosen_provider_relationships.each do |provider_relationship|
        provider_relationship.delivery_partner = delivery_partner
        provider_relationship.save!
      end
    end

    redirect_to admin_new_delivery_partner_success_path(delivery_partner: delivery_partner)
  rescue ActiveRecord::RecordInvalid
    render :'errors/internal_server_error'
  end

  def delivery_partner_success
    authorize DeliveryPartner, :create?
    session.delete(:new_supplier_form)
    session.delete(:lead_provider_form)
    session.delete(:delivery_partner_form)

    @delivery_partner = DeliveryPartner.find(params[:delivery_partner])
  end

  def show_users
    show
  end

  def show_lps
    show
  end

  def show_schools
    show
  end

private

  def show
    @delivery_partner = DeliveryPartner.find(params[:delivery_partner])
    authorize @delivery_partner, :show?
  end
end
