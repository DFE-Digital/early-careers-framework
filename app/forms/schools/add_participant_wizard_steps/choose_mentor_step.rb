# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class ChooseMentorStep < ::WizardStep
      attr_accessor :mentor_id

      validates :mentor_id, presence: true, if: -> { type == :ect },
        inclusion: { in: ->(wizard) { wizard.mentor_options.map(&:id) + %w[later] } }

      def self.permitted_params
        %i[
          mentor_id
        ]
      end

      def next_step
        if wizard.needs_to_confirm_appropriate_body?
          :confirm_appropriate_body
        else
          :check_answers
        end
      end

      def previous_step
        :what_we_need
      end
    end
  end
end
