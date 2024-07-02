# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class SuccessController < BaseController
      private

        def current_step
          :success
        end
      end
    end
  end
end
