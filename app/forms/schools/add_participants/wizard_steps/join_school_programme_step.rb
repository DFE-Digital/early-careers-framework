# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class JoinSchoolProgrammeStep < ::WizardStep
        attr_accessor :join_school_programme

        validates :join_school_programme, inclusion: { in: %w[yes no] }

        def self.permitted_params
          %i[
            join_school_programme
          ]
        end

        def next_step
          if join_school_programme?
            :check_answers
          else
            :cannot_add_manual_transfer
          end
        end

        def previous_step
          :continue_current_programme
        end

        def join_school_programme?
          join_school_programme == "yes"
        end
      end
    end
  end
end
