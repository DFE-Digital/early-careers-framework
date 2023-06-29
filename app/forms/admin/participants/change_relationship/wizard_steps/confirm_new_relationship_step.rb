# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ConfirmNewRelationshipStep < ::WizardStep
          attr_accessor :confirmed

          def self.permitted_params
            %i[
              confirmed
            ]
          end

          def expected?
            wizard.create_new_partnership? && wizard.selected_lead_provider.present? && wizard.selected_delivery_partner.present?
          end

          def next_step
            :none
          end

          def complete?
            true
          end
        end
      end
    end
  end
end
