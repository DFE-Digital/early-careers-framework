# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class YourselfStep < ::WizardStep
        attr_accessor :participant_type

        def self.permitted_params
          %i[
            participant_type
          ]
        end

        def next_step
          :trn
        end

        def previous_step
          :abort
        end

        # def before_render
        #   wizard.reset_form
        # end

        def before_save
          @participant_type = "self"
        end
      end
    end
  end
end
