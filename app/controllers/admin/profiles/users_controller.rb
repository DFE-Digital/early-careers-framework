# frozen_string_literal: true

module Admin
  module Profiles
    class UsersController < Admin::BaseController
      skip_after_action :verify_policy_scoped, only: :index
      skip_after_action :verify_authorized, only: :index

      def index
        redirect_to admin_admin_profiles_path(current_tab: :admin_admin_profiles) if params[:current_tab].nil? || params[:current_tab] == "admin_profiles"
        redirect_to admin_induction_coordinator_profiles_path(current_tab: :admin_induction_coordinator_profiles) if params[:current_tab] == "induction_coordinator_profiles"
        redirect_to admin_lead_provider_profiles_path(current_tab: :admin_lead_provider_profiles) if params[:current_tab] == "lead_provider_profiles"
      end
    end
  end
end
