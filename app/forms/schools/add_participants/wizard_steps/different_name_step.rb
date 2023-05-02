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
          if wizard.participant_exists?
            if wizard.ect_participant?
              :confirm_transfer
            else
              :confirm_mentor_transfer
            end
          elsif wizard.dqt_record_has_different_name?
            :known_by_another_name
          elsif wizard.found_participant_in_dqt? || wizard.sit_mentor?
            :none
          else
            :cannot_find_their_details
          end
        end

        def journey_complete?
          next_step == :none
        end
      end
    end
  end
end
