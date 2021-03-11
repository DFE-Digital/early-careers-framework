# frozen_string_literal: true

module Admin
  module Profiles
    class AdminProfilesController < Admin::BaseController
      before_action :set_admin_profile, only: %i[show destroy]
      skip_after_action :verify_policy_scoped, only: %i[show destroy]

      def index
        authorize AdminProfile, :index?
        admin_profiles = policy_scope(AdminProfile)
        @admin_profiles = Kaminari.paginate_array(admin_profiles).page(params[:page]).per(20)
        @page = @admin_profiles.current_page
        @total_pages = @admin_profiles.total_pages
      end

      def show
        authorize @admin_profile

      end

      def destroy
        authorize @admin_profile

        ActiveRecord::Base.transaction do
          @admin_profile.user.discard!
          @admin_profile.discard!
        end

        redirect_to admin_admin_profiles_path
      end

      private

      def set_admin_profile
        @admin_profile = AdminProfile.find(params[:id])
      end
    end
  end
end
