# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class AppropriateBodyAppointedStep < ::WizardStep
        attr_accessor :appropriate_body_appointed

        validates :appropriate_body_appointed, inclusion: { in: %w[yes no], message: "Specify whether you have appointed an appropriate body" }

        def self.permitted_params
          %i[appropriate_body_appointed]
        end

        def appropriate_body_appointed?
          appropriate_body_appointed == "yes"
        end

        def body_appointed_choices
          [
            OpenStruct.new(id: "yes", name: "Yes"),
            OpenStruct.new(id: "no", name: "No, I will appoint an appropriate body later"),
          ]
        end

        def complete?
          !appropriate_body_appointed?
        end

        def expected?
          wizard.keep_providers? || wizard.what_changes.present? || wizard.how_will_you_run_training.present?
        end

        def next_step
          appropriate_body_appointed? ? :appropriate_body : :complete
        end
      end
    end
  end
end
