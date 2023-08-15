# frozen_string_literal: true

require_relative "ect"

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class EctNoValidation < NewSeeds::Scenarios::Participants::Ects::Ect
          def build(appropriate_body: nil, **ect_builder_args)
            # keep falsy values intact
            ect_builder_args[:sparsity_uplift] = true unless ect_builder_args.key?(:sparsity_uplift)
            ect_builder_args[:pupil_premium_uplift] = true unless ect_builder_args.key?(:pupil_premium_uplift)

            ect_builder_args[:teacher_profile_args] ||= {}
            ect_builder_args[:teacher_profile_args][:trn] = true unless ect_builder_args[:teacher_profile_args].key?(:trn)
            ect_builder_args[:teacher_profile_args][:trn] = nil

            super(induction_start_date: nil, **ect_builder_args)
            with_induction_record(induction_programme: school_cohort.default_induction_programme, appropriate_body:)

            self
          end
        end
      end
    end
  end
end
