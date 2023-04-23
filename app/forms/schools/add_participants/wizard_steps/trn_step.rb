# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
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

        # def previous_step
        #   if wizard.sit_mentor?
        #     :abort
        #   else
        #     :what_we_need
        #   end
        # end
      end
    end
  end
end
