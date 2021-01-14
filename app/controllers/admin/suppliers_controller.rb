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
    @lead_provider = LeadProvider.new
    authorize @lead_provider
  end

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
