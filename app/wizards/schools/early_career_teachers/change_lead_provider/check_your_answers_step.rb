# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class CheckYourAnswersStep < StoredStep
        attr_accessor :complete

        def self.permitted_params
          [:complete]
        end

        def previous_step
          :lead_provider
        end

        def next_step
          :success
        end
      end
    end
  end
end
