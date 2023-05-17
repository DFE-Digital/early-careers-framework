# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class AppropriateBodyTypeStep < ::WizardStep
        APPROPRIATE_BODY_TYPE_CHOICES = {
          local_authority: "Local authority",
          national: "National organisation",
          teaching_school_hub: "Teaching school hub",
        }.freeze

        attr_accessor :appropriate_body_type

        validates :appropriate_body_type, inclusion: { in: ->(form) { form.choices.map(&:id).map(&:to_s) } }

        def self.permitted_params
          %i[appropriate_body_type]
        end

        def choices
          APPROPRIATE_BODY_TYPE_CHOICES.map { |id, name| OpenStruct.new(id:, name:) }
        end

        def expected?
          wizard.appropriate_body_appointed?
        end

        def next_step
          :appropriate_body
        end
      end
    end
  end
end
