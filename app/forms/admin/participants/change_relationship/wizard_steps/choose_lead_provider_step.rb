# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ChooseLeadProviderStep < ::WizardStep
          attr_accessor :lead_provider_id

          validates :lead_provider_id, presence: true

          def self.permitted_params
            %i[
              lead_provider_id
            ]
          end

          def expected?
            wizard.create_new_partnership?
          end

          def next_step
            :choose_delivery_partner
          end

          def options
            wizard.available_providers_for_participant_cohort
          end
        end
      end
    end
  end
end
