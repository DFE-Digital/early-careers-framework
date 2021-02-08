# frozen_string_literal: true

class Admin::SuppliersController < Admin::BaseController
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  def index
    lead_providers = policy_scope(LeadProvider)
    delivery_partners = policy_scope(DeliveryPartner)
    sorted_suppliers = (lead_providers + delivery_partners).sort_by(&:name)
    @suppliers = Kaminari.paginate_array(sorted_suppliers).page(params[:page]).per(1)
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
    @new_supplier_form = NewSupplierForm.new(params.require(:new_supplier_form).permit(:name))

    render :new and return unless @new_supplier_form.valid?(:name)

    session[:new_supplier_form] = (session[:new_supplier_form] || {}).merge({ name: @new_supplier_form.name })
    redirect_to admin_new_supplier_type_path
  end

  def new_supplier_type
    @new_supplier_form = NewSupplierForm.new(session[:new_supplier_form])
    skip_authorization
  end

  def receive_new_supplier_type
    new_form_params = session[:new_supplier_form].merge(params.require(:new_supplier_form).permit(:type))
    @new_supplier_form = NewSupplierForm.new(new_form_params)

    unless @new_supplier_form.valid?(:type)
      skip_authorization
      render :new_supplier_type and return
    end

    session[:new_supplier_form] = new_form_params

    case @new_supplier_form.type
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
end
