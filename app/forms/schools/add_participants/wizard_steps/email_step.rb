# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class EmailStep < ::WizardStep
        attr_accessor :email

        validates :email, presence: true, notify_email: true

        def self.permitted_params
          %i[
            email
          ]
        end

        def next_step
          if wizard.transfer?
            :joining_date
          else
            :start_date
          end
        end

        def previous_step
          :date_of_birth
        end
      end
    end
  end
end
