# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ReasonForChangeStep < ::WizardStep
          attr_accessor :reason_for_change

          VALID_OPTIONS = %w[wrong_programme change_of_circumstances]

          validates :reason_for_change, presence: true, inclusion: { in: VALID_OPTIONS }

          def self.permitted_params
            %i[
              reason_for_change
            ]
          end

          # first step
          def expected?
            true
          end

          def next_step
            reason_for_change.to_sym
          end

          def options
            VALID_OPTIONS.map do |option|
              OpenStruct.new(id: option, name: wizard.i18n_text(key: option, scope: "reason_for_change.options")) 
            end
          end

        end
      end
    end
  end
end
