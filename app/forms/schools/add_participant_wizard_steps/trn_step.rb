# frozen_string_literal: true

module Schools
  module AddParticipantWizardSteps
    class TrnStep < ::WizardStep
      attr_accessor :trn

      validates :trn, presence: true, teacher_reference_number: true

      def self.permitted_params
        %i[
          trn
        ]
      end

      def next_step
        :date_of_birth
      end

      def previous_step
        :name
      end
    end
  end
end
