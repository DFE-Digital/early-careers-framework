# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class IntroController < BaseController
      private

        def current_step
          :intro
        end
      end
    end
  end
end
