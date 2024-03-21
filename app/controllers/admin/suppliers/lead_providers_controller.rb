# frozen_string_literal: true

module Admin
  module Suppliers
    class LeadProvidersController < Admin::BaseController
      before_action :set_lead_provider, only: %i[show]
      skip_after_action :verify_policy_scoped

      def show; end

    private

      def set_lead_provider
        @lead_provider = LeadProvider.find(params[:id])
        authorize @lead_provider
      end
    end
  end
end
