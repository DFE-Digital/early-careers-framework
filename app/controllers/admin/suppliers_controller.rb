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
end
