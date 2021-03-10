# frozen_string_literal: true

module Admin
  module Profiles
    class LeadProviderProfilesController < Admin::BaseController
      skip_after_action :verify_policy_scoped, only: [:show, :delete]

      def index
        authorize LeadProviderProfile, :index?
        lead_provider_profiles = policy_scope(LeadProviderProfile)
        @lead_provider_profiles = Kaminari.paginate_array(lead_provider_profiles).page(params[:page]).per(20)
        @page = @lead_provider_profiles.current_page
        @total_pages = @lead_provider_profiles.total_pages
      end

      def show
        authorize LeadProviderProfile, :show?
        @lead_provider_profile = LeadProviderProfile.find(params[:id])
      end

      def delete
        authorize LeadProviderProfile, :delete?
        LeadProviderProfile.find(params[:id])
      end
    end
  end
end
