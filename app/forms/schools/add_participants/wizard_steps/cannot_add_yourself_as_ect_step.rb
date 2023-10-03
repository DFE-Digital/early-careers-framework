# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddYourselfAsECTStep < ::WizardStep
        attr_accessor :participant_type

        validates :participant_type, inclusion: { in: %w[mentor return] }

        def self.permitted_params
          %i[
            participant_type
          ]
        end

        def next_step
          if switch_to_mentor?
            :yourself
          else
            :abort
          end
        end

        def switch_to_mentor?
          participant_type == "mentor"
        end
      end
    end
  end
end
