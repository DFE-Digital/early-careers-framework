# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class WhatWeNeedStep < ::WizardStep
        def next_step
          :name
        end

        def previous_step
          :who
        end

        def before_render
          wizard.reset_form
        end
      end
    end
  end
end
