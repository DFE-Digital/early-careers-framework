# frozen_string_literal: true

class Admin::SuppliersController < Admin::BaseController
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  def index
    lead_providers = policy_scope(LeadProvider)
    delivery_partners = policy_scope(DeliveryPartner)
    sorted_suppliers = (lead_providers + delivery_partners).sort_by(&:name)
    @suppliers = Kaminari.paginate_array(sorted_suppliers).page(params[:page]).per(20)
    @page = @suppliers.current_page
    @total_pages = @suppliers.total_pages
  end

  def new
    if params[:continue]
      @new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
    else
      session.delete(:new_supplier_form)
      session.delete(:lead_provider_form)
      @new_supplier_form = NewSupplierForm.new
    end
    skip_authorization
  end

  def receive_new
    skip_authorization
    if params.dig(:new_supplier_form, :name).blank?
      @new_supplier_form = NewSupplierForm.new
      @new_supplier_form.errors.add(:name, :blank, message: "Enter a name")
      render :new and return
    end

    if session[:new_supplier_form]
      session[:new_supplier_form].merge!(params.require(:new_supplier_form).permit(:name))
    else
      session[:new_supplier_form] = NewSupplierForm.new(params.require(:new_supplier_form).permit(:name))
    end

    redirect_to admin_new_supplier_type_path
  end

  def new_supplier_type
    @new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
    skip_authorization
  end

  def receive_new_supplier_type
    supplier_type = params.dig(:new_supplier_form, :type)
    if supplier_type.blank?
      skip_authorization
      @new_supplier_form = NewSupplierForm.new
      @new_supplier_form.errors.add(:type, :blank, message: "Choose one")
      render :new_supplier_type and return
    end

    session[:new_supplier_form].merge!(params.require(:new_supplier_form).permit(:type))

    case supplier_type
    when "lead_provider"
      authorize LeadProvider, :create?
      redirect_to admin_new_lead_provider_cip_path
    when "delivery_partner"
      authorize DeliveryPartner, :create?
      redirect_to admin_new_delivery_partner_lps_path
    else
      raise Exception, "Unreachable code"
    end
  end

  # region Lead Providers
  def choose_cip
    authorize LeadProvider, :create?

    new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
    if session[:lead_provider_form].nil?
      session[:lead_provider_form] = { name: new_supplier_form.name }
    else
      session[:lead_provider_form].merge!({ name: new_supplier_form.name })
    end

    @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
  end

  def receive_cip
    authorize LeadProvider, :create?

    if params.dig(:lead_provider_form, :cip).blank?
      @lead_provider_form = LeadProviderForm.new
      @lead_provider_form.errors.add(:cip, :blank, message: "Choose one")
      render :choose_cip and return
    end

    session[:lead_provider_form].merge!(params.require(:lead_provider_form).permit(:cip))
    redirect_to admin_new_lead_provider_cohorts_path
  end

  def choose_cohorts
    authorize LeadProvider, :create?
    @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
  end

  def receive_cohorts
    authorize LeadProvider, :create?
    cohorts = params.dig(:lead_provider_form, :cohorts)
                    .keep_if(&:present?)

    session[:lead_provider_form].merge!({ cohorts: cohorts })
    redirect_to admin_new_lead_provider_review_path
  end

  def review_lead_provider
    authorize LeadProvider, :create?

    @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
  end

  def create_lead_provider
    @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])

    @lead_provider = LeadProvider.new(name: @lead_provider_form.name, cohorts: @lead_provider_form.chosen_cohorts)
    authorize @lead_provider, :create?

    ActiveRecord::Base.transaction do
      @lead_provider.save!
      @lead_provider_form.chosen_cohorts.each do |cohort|
        LeadProviderCip.create!(cohort: cohort, cip: @lead_provider_form.chosen_cip, lead_provider: @lead_provider)
      end
    end

    redirect_to admin_new_lead_provider_success_path(lead_provider: @lead_provider)
  rescue ActiveRecord::RecordInvalid
    render :'errors/internal_server_error'
  end

  def lead_provider_success
    authorize LeadProvider, :create?
    session.delete(:new_supplier_form)
    session.delete(:lead_provider_form)

    @lead_provider = LeadProvider.find(params[:lead_provider])
  end

  # endregion

  # region Delivery Partners
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
    params.dig(:delivery_partner_form, :lead_providers).keep_if(&:present?).each do |lead_provider|
      chosen_cohorts = params.dig(
        :delivery_partner_form,
        lead_provider.to_sym,
        :cohorts,
      ).keep_if(&:present?)

      unless chosen_cohorts.any?
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

  # endregion

  def create
    @lead_provider = LeadProvider.new(permitted_attributes(LeadProvider))
    authorize @lead_provider

    if @lead_provider.save
      redirect_to admin_suppliers_path
    else
      render :new
    end
  end

  def edit
    @lead_provider = LeadProvider.find(params.require(:id))
    authorize @lead_provider
  end

  def update
    @lead_provider = LeadProvider.find(params.fetch(:id))
    authorize @lead_provider

    if @lead_provider.update(permitted_attributes(@lead_provider))
      redirect_to admin_suppliers_path
    else
      render :edit
    end
  end
end
