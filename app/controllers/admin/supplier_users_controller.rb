# frozen_string_literal: true

class Admin::SupplierUsersController < Admin::BaseController
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  before_action :set_suppliers, only: %i[new receive_supplier]
  before_action :form_from_session, only: %i[user_details review create success]

  def index
    lead_providers = policy_scope(LeadProvider).joins(:users).includes(:users)
    delivery_partners = policy_scope(DeliveryPartner).joins(:users).includes(:users)
    sorted_users = (lead_providers + delivery_partners).flat_map(&:users).sort_by(&:full_name)
    @users = Kaminari.paginate_array(sorted_users).page(params[:page]).per(20)
    @page = @users.current_page
    @total_pages = @users.total_pages
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
    user = @supplier_user_form.save!
    redirect_to admin_new_supplier_user_success_path(user_id: user.id)
  end

  def success
    @user = User.find(params[:user_id])
    authorize @user, :show?
    @supplier = @supplier_user_form.chosen_supplier.name

    session.delete(:supplier_user_form)
  end

private

  def set_suppliers
    @supplier_user_form = SupplierUserForm.new

    lead_providers = policy_scope(LeadProvider)
    delivery_partners = policy_scope(DeliveryPartner)
    @suppliers = (lead_providers + delivery_partners).sort_by(&:name)
  end

  def form_from_session
    @supplier_user_form = SupplierUserForm.new(session[:supplier_user_form])
  end
end
