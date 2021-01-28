# frozen_string_literal: true

class Admin::SupplierUsersController < Admin::BaseController
  skip_after_action :verify_authorized, only: :index
  skip_after_action :verify_policy_scoped, except: :index

  def index
    lead_providers = policy_scope(LeadProvider).joins(:users).includes(:users)
    delivery_partners = policy_scope(DeliveryPartner).joins(:users).includes(:users)
    sorted_users = (lead_providers + delivery_partners).flat_map(&:users).sort_by(&:name)
    @users = Kaminari.paginate_array(sorted_users).page(params[:page]).per(20)
    @page = @users.current_page
    @total_pages = @users.total_pages
  end
end
