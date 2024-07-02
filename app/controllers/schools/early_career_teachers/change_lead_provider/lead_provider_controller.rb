# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class LeadProviderController < BaseController
        before_action :lead_providers

      private

        def lead_providers
          @lead_providers ||= LeadProvider.all.order(:name)
        end

        def current_step
          :lead_provider
        end
      end
    end
  end
end
