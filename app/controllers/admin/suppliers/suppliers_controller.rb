# frozen_string_literal: true

module Admin
  module Suppliers
    class SuppliersController < Admin::BaseController
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

      def create
        skip_authorization
        @new_supplier_form = NewSupplierForm.new(params.require(:new_supplier_form).permit(:name))

        render :new and return unless @new_supplier_form.valid?(:name)

        session[:new_supplier_form] = (session[:new_supplier_form] || {}).merge({ name: @new_supplier_form.name })
        redirect_to supplier_type_admin_new_supplier_index_path
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
          redirect_to choose_cip_admin_lead_providers_path
        when "delivery_partner"
          authorize DeliveryPartner, :create?
          redirect_to choose_lps_admin_delivery_partners_path
        else
          raise Exception, "Unreachable code"
        end
      end
    end
  end
end
