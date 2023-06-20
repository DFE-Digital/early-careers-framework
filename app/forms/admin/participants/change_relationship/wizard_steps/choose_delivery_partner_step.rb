# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ChooseDeliveryPartnerStep < ::WizardStep
          attr_accessor :delivery_partner_id

          validates :delivery_partner_id, presence: true

          def self.permitted_params
            %i[
              delivery_partner_id
            ]
          end

          def expected?
            wizard.create_new_partnership? && wizard.selected_lead_provider.present?
          end

          def next_step
            :confirm_new_relationship
          end

          def options
            wizard.available_delivery_partners_for_provider
          end
        end
      end
    end
  end
end
