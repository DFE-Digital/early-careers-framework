# frozen_string_literal: true

module Admin
  module Profiles
    class LeadProviderProfilesController < Admin::BaseController
      before_action :set_lead_provider_profile, only: %i[show destroy]
      skip_after_action :verify_policy_scoped, only: %i[show destroy]

      def index
        authorize LeadProviderProfile, :index?
        lead_provider_profiles = policy_scope(LeadProviderProfile)
        @lead_provider_profiles = Kaminari.paginate_array(lead_provider_profiles).page(params[:page]).per(20)
        @page = @lead_provider_profiles.current_page
        @total_pages = @lead_provider_profiles.total_pages
      end

      def show
        authorize @lead_provider_profile
      end

      def destroy
        authorize @lead_provider_profile
        ActiveRecord::Base.transaction do
          @lead_provider_profile.user.discard!
          @lead_provider_profile.discard!
        end

        redirect_to admin_lead_provider_profiles_path
      end

      private

      def set_lead_provider_profile
        @lead_provider_profile = LeadProviderProfile.find(params[:id])
      end
    end
  end
end
