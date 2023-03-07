# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class ConfirmAppropriateBodyStep < ::WizardStep
      attr_accessor :appropriate_body_confirmed, :appropriate_body_id

      def self.permitted_params
        %i[
          appropriate_body_confirmed
        ]
      end

      def next_step
        :check_answers
      end

      def previous_step
        if wizard.ect_participant? && wizard.mentor_options.any?
          :choose_mentor
        else
          :start_date
        end
      end
    end
  end
end
