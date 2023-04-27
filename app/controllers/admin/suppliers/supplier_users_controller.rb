# frozen_string_literal: true

module Admin
  module Suppliers
    class SupplierUsersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index
      skip_after_action :verify_policy_scoped

      before_action :set_suppliers, only: %i[new receive_supplier]
      before_action :form_from_session, only: %i[user_details review create]

      def index
        @query = params[:query]
        @pagy, @lead_providers = pagy_array(scoped_lead_providers, page: params[:page], items: 20)
        @page = @pagy.page
        @total_pages = @pagy.pages
      end

      def new
        authorize User, :new?

        if params[:continue]
          form_from_session
        else
          session.delete(:supplier_user_form)
          @supplier_user_form = SupplierUserForm.new
        end
      end

      def receive_supplier
        authorize User, :new?
        @supplier_user_form = SupplierUserForm.new(params.require(:supplier_user_form).permit(:supplier))

        render :new and return unless @supplier_user_form.valid?(:supplier)

        session[:supplier_user_form] = (session[:supplier_user_form] || {}).merge({ supplier: @supplier_user_form.supplier })
        redirect_to admin_new_supplier_user_details_path
      end

      def user_details
        authorize User, :new?
      end

      def receive_user_details
        authorize User, :new?

        @supplier_user_form = SupplierUserForm.new(
          session[:supplier_user_form].merge(
            params.require(:supplier_user_form).permit(:full_name, :email),
          ),
        )

        render :user_details and return unless @supplier_user_form.valid?(:details)

        session[:supplier_user_form] = @supplier_user_form.serializable_hash
        redirect_to admin_new_supplier_user_review_path
      end

      def review
        authorize User, :new?
      end

      def create
        authorize User
        authorize LeadProviderProfile

        @supplier_user_form.save!
        session.delete(:supplier_user_form)

        set_success_message(heading: "User added")
        redirect_to admin_supplier_users_path
      end

    private

      def set_suppliers
        @supplier_user_form = SupplierUserForm.new

        @suppliers = policy_scope(LeadProvider).sort_by(&:name)
      end

      def form_from_session
        @supplier_user_form = SupplierUserForm.new(session[:supplier_user_form])
      end

      def scoped_lead_providers
        return policy_scope(LeadProviderProfile).includes(:user).order("users.full_name asc") if params[:query].blank?

        ::LeadProviderProfiles::SearchQuery
          .new(query: params[:query], scope: policy_scope(LeadProviderProfile))
          .call
      end
    end
  end
end
