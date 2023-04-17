# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class WhatWeNeedStep < ::WizardStep
        def next_step
          :name
        end
      end
    end
  end
end
