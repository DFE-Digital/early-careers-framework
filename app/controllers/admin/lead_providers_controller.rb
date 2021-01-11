# frozen_string_literal: true

class Admin::LeadProvidersController < Admin::BaseController
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  def index
    @lead_providers = policy_scope(LeadProvider)
  end

  def new
    @lead_provider = LeadProvider.new
    authorize @lead_provider
  end

  def create
    @lead_provider = LeadProvider.new(permitted_attributes(LeadProvider))
    authorize @lead_provider

    if @lead_provider.save
      redirect_to admin_lead_providers_path
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
      redirect_to admin_lead_providers_path
    else
      render :edit
    end
  end
end
