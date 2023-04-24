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
          if wizard.changing_answer?
            if wizard.nino
              :still_cannot_find_their_details
            else
              :cannot_find_their_details
            end
          else
            :date_of_birth
          end
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
