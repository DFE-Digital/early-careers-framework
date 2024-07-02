# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class CheckYourAnswersController < BaseController
      private

        def current_step
          :check_your_answers
        end
      end
    end
  end
end
