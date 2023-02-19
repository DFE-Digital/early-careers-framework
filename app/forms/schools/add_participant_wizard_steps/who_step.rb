# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class WhoStep < ::WizardStep
      attr_accessor :participant_type

      validates :participant_type, presence: true, inclusion: { in: %w[ect mentor self transfer] }

      def self.permitted_params
        %i[
          participant_type
        ]
      end

      def next_step
        :what_we_need
      end

      def previous_step
      end
    end
  end
end
