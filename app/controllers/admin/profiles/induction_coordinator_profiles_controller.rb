# frozen_string_literal: true

module Admin
  module Profiles
    class InductionCoordinatorProfilesController < Admin::BaseController
      before_action :set_induction_coordinator_profile, only: %i[show destroy]
      skip_after_action :verify_policy_scoped, only: %i[show destroy]

      def index
        authorize InductionCoordinatorProfile, :index?
        induction_coordinator_profiles = policy_scope(InductionCoordinatorProfile)
        @induction_coordinator_profiles = Kaminari.paginate_array(induction_coordinator_profiles).page(params[:page]).per(20)
        @page = @induction_coordinator_profiles.current_page
        @total_pages = @induction_coordinator_profiles.total_pages
      end

      def show
        authorize @induction_coordinator_profile
      end

      def destroy
        authorize @induction_coordinator_profile
        ActiveRecord::Base.transaction do
          @induction_coordinator_profile.user.discard!
          @induction_coordinator_profile.discard!
        end

        redirect_to admin_induction_coordinator_profiles_path
      end

      private

      def set_induction_coordinator_profile
        @induction_coordinator_profile = InductionCoordinatorProfile.find(params[:id])
      end
    end
  end
end
