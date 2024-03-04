# frozen_string_literal: true

require_relative "ect"

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class EctInTraining < NewSeeds::Scenarios::Participants::Ects::Ect
          def build(appropriate_body: nil, **ect_builder_args)
            ect_builder_args[:sparsity_uplift] = true unless ect_builder_args.key?(:sparsity_uplift)
            ect_builder_args[:pupil_premium_uplift] = true unless ect_builder_args.key?(:pupil_premium_uplift)

            super(**ect_builder_args)
            with_validation_data
            with_eligibility
            with_induction_record(induction_programme: school_cohort.default_induction_programme, appropriate_body:)

            self
          end
        end
      end
    end
  end
end
