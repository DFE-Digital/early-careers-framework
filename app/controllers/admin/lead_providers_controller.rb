# frozen_string_literal: true

class Admin::LeadProvidersController < Admin::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

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
                &.keep_if(&:present?)

    if cohorts.blank?
      @lead_provider_form = LeadProviderForm.new
      @lead_provider_form.errors.add(:cohorts, :blank, message: "Choose one or more")
      render :choose_cohorts and return
    end

    session[:lead_provider_form].merge!({ cohorts: cohorts })
    redirect_to admin_new_lead_provider_review_path
  end

  def review
    authorize LeadProvider, :create?

    @lead_provider_form = LeadProviderForm.new(session[:lead_provider_form])
  end

  def create
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
    raise ActionController::ActionControllerError
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

  def show_details
    show
  end

  def show_users
    show
  end

  def show_dps
    show
  end

  def show_schools
    show
  end

private

  def show
    @lead_provider = LeadProvider.find(params[:lead_provider])
    authorize @lead_provider, :show?
  end
end
