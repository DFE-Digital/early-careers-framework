# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class ContactProvidersController < BaseController
      private

        def current_step
          :contact_providers
        end
      end
    end
  end
end
