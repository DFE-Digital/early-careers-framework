# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class StartController < BaseController
      private

        def current_step
          :start
        end
      end
    end
  end
end
