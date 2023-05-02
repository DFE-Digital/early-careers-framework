# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ContinueCurrentProgrammeStep < ::WizardStep
        attr_accessor :continue_current_programme

        validates :continue_current_programme, inclusion: { in: %w[yes no] }

        def self.permitted_params
          %i[
            continue_current_programme
          ]
        end

        def next_step
          if continue_current_programme?
            :check_answers
          else
            :join_school_programme
          end
        end

        def continue_current_programme?
          continue_current_programme == "yes"
        end

        # when changing this choice, should we return to check answers or
        # revisit the subsequent page
        def revisit_next_step?
          !continue_current_programme?
        end
      end
    end
  end
end
