# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class EmailController < BaseController
      private

        def current_step
          :email
        end
      end
    end
  end
end
