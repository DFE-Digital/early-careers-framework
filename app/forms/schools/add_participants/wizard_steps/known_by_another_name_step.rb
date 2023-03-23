# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class KnownByAnotherNameStep < ::WizardStep
        attr_accessor :known_by_another_name

        validates :known_by_another_name, inclusion: { in: %w[yes no] }

        def before_render
          wizard.reset_known_by_another_name_response
        end

        def self.permitted_params
          %i[
            known_by_another_name
          ]
        end

        def next_step
          if known_by_another_name?
            :different_name
          else
            :cannot_add_mismatch
          end
        end

        def previous_step
          :date_of_birth
        end

        def known_by_another_name?
          known_by_another_name == "yes"
        end
      end
    end
  end
end
