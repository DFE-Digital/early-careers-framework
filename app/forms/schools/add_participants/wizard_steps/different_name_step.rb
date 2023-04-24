# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class DifferentNameStep < ::WizardStep
        attr_accessor :full_name

        validates :full_name, presence: true

        def self.permitted_params
          %i[
            full_name
          ]
        end

        def next_step
          if wizard.dqt_record?
            wizard.next_step_from_record_check
          else
            :known_by_another_name
          end
        end
      end
    end
  end
end
