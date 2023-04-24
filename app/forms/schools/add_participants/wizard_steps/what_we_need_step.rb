# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class WhatWeNeedStep < ::WizardStep
        def next_step
          :name
        end

        # def previous_step
        #   :participant_type
        # end
      end
    end
  end
end
