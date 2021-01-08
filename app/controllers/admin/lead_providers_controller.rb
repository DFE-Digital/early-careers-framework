# frozen_string_literal: true

class Admin::LeadProvidersController < Admin::BaseController
  def index
    @lead_providers = LeadProvider.all
  end

  def new
    @lead_provider = LeadProvider.new
  end

  def create
    @lead_provider = LeadProvider.new(name: params.dig(:lead_provider, :name))

    if @lead_provider.save
      redirect_to admin_lead_providers_path
    else
      render :new
    end
  end

  def edit
    @lead_provider = LeadProvider.find(params.require(:id))
  end

  def update
    @lead_provider = LeadProvider.find(params.fetch(:id))

    if @lead_provider.update(name: params.dig(:lead_provider, :name))
      redirect_to admin_lead_providers_path
    else
      render :edit
    end
  end
end
