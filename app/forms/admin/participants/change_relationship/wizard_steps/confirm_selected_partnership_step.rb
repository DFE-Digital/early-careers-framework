# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ConfirmSelectedPartnershipStep < ::WizardStep
          attr_accessor :confirmed

          def self.permitted_params
            %i[
              confirmed
            ]
          end

          def expected?
            wizard.selected_partnership.present? && !wizard.create_new_partnership?
          end

          def complete?
            true
          end

          def next_step
            :none
          end

          def selected_partnership_title
            "You are going to use the #{wizard.default_partnership_selected? ? 'default partnership' : 'following relationship'}"
          end
        end
      end
    end
  end
end
