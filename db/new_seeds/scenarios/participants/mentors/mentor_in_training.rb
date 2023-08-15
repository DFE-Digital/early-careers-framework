# frozen_string_literal: true

require_relative "mentor"

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentorInTraining < NewSeeds::Scenarios::Participants::Mentors::Mentor
          # noinspection RubyParameterNamingConvention
          def build(number_of_extra_mentees: 0, **mentor_builder_args)
            number_of_mentees = 1 + number_of_extra_mentees

            # keep falsy values intact
            mentor_builder_args[:sparsity_uplift] = true unless mentor_builder_args.key?(:sparsity_uplift)
            mentor_builder_args[:pupil_premium_uplift] = true unless mentor_builder_args.key?(:pupil_premium_uplift)

            super(number_of_mentees:, **mentor_builder_args)
            with_validation_data
            with_eligibility
            with_induction_record(induction_programme: school_cohort.default_induction_programme)

            self
          end
        end
      end
    end
  end
end
