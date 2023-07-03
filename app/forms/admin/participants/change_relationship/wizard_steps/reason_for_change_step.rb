# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ReasonForChangeStep < ::JourneyWizard::Step
          attr_accessor :reason_for_change

          VALID_OPTIONS = %w[wrong_programme change_of_circumstances].freeze

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
            if mistake? && !wizard.programme_can_be_changed?
              # if there are declarations then we cannot proceed with the journey
              :cannot_change_programme
            else
              # FIXME: what if there are no options, should we go straight to create a new one?
              :change_training_programme
            end
          end

          def options
            VALID_OPTIONS.map do |option|
              OpenStruct.new(id: option, name: wizard.i18n_text(key: option, scope: "reason_for_change.options"))
            end
          end

        private

          def mistake?
            reason_for_change == "wrong_programme"
          end
        end
      end
    end
  end
end
