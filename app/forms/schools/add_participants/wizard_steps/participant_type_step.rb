# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ParticipantTypeStep < ::WizardStep
        attr_accessor :participant_type

        validates :participant_type, presence: true, inclusion: { in: %w[ect mentor self transfer] }

        def self.permitted_params
          %i[
            participant_type
          ]
        end

        def next_step
          if participant_type == "self"
            :yourself
          else
            :what_we_need
          end
        end
      end
    end
  end
end
