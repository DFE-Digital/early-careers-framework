# frozen_string_literal: true

module Admin
  module Profiles
    class InductionCoordinatorProfilesController < Admin::BaseController
      skip_after_action :verify_policy_scoped, only: %i[show destroy]

      def index
        authorize InductionCoordinatorProfile, :index?
        induction_coordinator_profiles = policy_scope(InductionCoordinatorProfile)
        @induction_coordinator_profiles = Kaminari.paginate_array(induction_coordinator_profiles).page(params[:page]).per(20)
        @page = @induction_coordinator_profiles.current_page
        @total_pages = @induction_coordinator_profiles.total_pages
      end

      def show
        authorize InductionCoordinatorProfile, :show?
        @induction_coordinator_profile = InductionCoordinatorProfile.find(params[:id])
      end

      def destroy
        authorize InductionCoordinatorProfile, :destroy?
        ActiveRecord::Base.transaction do
          profile = InductionCoordinatorProfile.find(params[:id])
          profile.user.discard!
          profile.discard!
        end

        redirect_to admin_induction_coordinator_profiles_path
      end
    end
  end
end
