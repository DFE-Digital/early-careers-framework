# frozen_string_literal: true

module Finance
  module BandingTracker
    class ProviderChoicesController < BaseController
      def new
        @providers = LeadProvider.all
        choose_provider_form
      end

      def create
        choose_provider_form.attributes = choose_provider_params

        return redirect_to finance_banding_tracker_provider_path(id: choose_provider_form.id) if choose_provider_form.valid?

        @providers = LeadProvider.all
        render :new
      end

    private

      def choose_provider_params
        params
          .require(:finance_banding_tracker_choose_provider)
          .permit(:id)
      end

      def choose_provider_form
        @choose_provider_form ||= ChooseProvider.new
      end
    end
  end
end
