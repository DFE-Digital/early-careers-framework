# frozen_string_literal: true

class Admin::LeadProvidersController < ApplicationController
  def index
    @lead_providers = LeadProvider.all
  end

  def new
    @lead_provider = LeadProvider.new
  end

  def create
    if params[:lead_provider][:name].blank?
      @lead_provider = LeadProvider.new
      @lead_provider.errors.add(:name, "Enter a name")
      render :new and return
    end

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

    if params[:lead_provider][:name].blank?
      @lead_provider.errors.add(:name, "Enter a name")
      render :edit and return
    end

    @lead_provider.update!(name: params.dig(:lead_provider, :name))

    redirect_to admin_lead_providers_path
  end
end
