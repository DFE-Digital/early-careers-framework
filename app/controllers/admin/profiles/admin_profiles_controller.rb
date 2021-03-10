# frozen_string_literal: true

module Admin
  module Profiles
    class AdminProfilesController < Admin::BaseController
      skip_after_action :verify_policy_scoped, only: %i[show destroy]
      skip_after_action :verify_authorized

      def index
        authorize AdminProfile, :index?
        admin_profiles = policy_scope(AdminProfile)
        @admin_profiles = Kaminari.paginate_array(admin_profiles).page(params[:page]).per(20)
        @page = @admin_profiles.current_page
        @total_pages = @admin_profiles.total_pages
      end

      def show
        authorize AdminProfile, :show?
        @admin_profile = AdminProfile.find(params[:id])
      end

      def destroy
        authorize AdminProfile, :destroy?
        AdminProfile.find(params[:id]).discard!
        redirect_to admin_admin_profiles_path
      end
    end
  end
end
