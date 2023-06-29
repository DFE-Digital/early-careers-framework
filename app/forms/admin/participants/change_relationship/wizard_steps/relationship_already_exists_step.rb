# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class RelationshipAlreadyExistsStep < ::WizardStep
          def expected?
            wizard.create_new_partnership? && wizard.selected_lead_provider.present?
          end

          def next_step
            :none
          end
        end
      end
    end
  end
end
