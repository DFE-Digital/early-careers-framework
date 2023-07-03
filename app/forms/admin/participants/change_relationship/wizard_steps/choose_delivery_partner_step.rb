# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ChooseDeliveryPartnerStep < ::JourneyWizard::Step
          attr_accessor :delivery_partner_id

          validates :delivery_partner_id, presence: true

          delegate :cohort, :school, :lead_provider_id, to: :wizard

          def self.permitted_params
            %i[
              delivery_partner_id
            ]
          end

          def expected?
            wizard.create_new_partnership? && wizard.selected_lead_provider.present?
          end

          def next_step
            if partnership_exists?
              :relationship_already_exists
            else
              :confirm_new_relationship
            end
          end

          def options
            wizard.available_delivery_partners_for_provider
          end

        private

          def partnership_exists?
            Partnership.where(cohort:, school:, lead_provider_id:, delivery_partner_id:).exists?
          end
        end
      end
    end
  end
end
