# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class EmailStep < ::WizardStep
      attr_accessor :email

      validates :email, presence: true, notify_email: true

      def self.permitted_params
        %i[
          email
        ]
      end

      def next_step
        :start_date
      end

      def previous_step
        :date_of_birth
      end
    end
  end
end
