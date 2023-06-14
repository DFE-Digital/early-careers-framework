# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class CannotChangeProgrammeStep < ::WizardStep
          def expected?
            wizard.reason_for_change_mistake? && !wizard.programme_can_be_changed?
          end

          def next_step
            :none
          end
        end
      end
    end
  end
end
