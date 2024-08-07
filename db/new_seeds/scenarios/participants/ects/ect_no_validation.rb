# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class EctNoValidation
          delegate :participant_profile,
                   :participant_identity,
                   :school_cohort,
                   :teacher_profile,
                   :user,
                   to: :ect_builder

          def initialize(school_cohort:, full_name: nil, email: nil)
            @ect_builder = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:, full_name:, email:)
          end

          def build(sparsity_uplift: true, pupil_premium_uplift: true, appropriate_body: nil, **ect_builder_args)
            ect_builder_args.merge!({ teacher_profile_args: { trn: nil } })

            @ect_builder.build(sparsity_uplift:, pupil_premium_uplift:, induction_start_date: nil, **ect_builder_args)
                        .with_induction_record(induction_programme: school_cohort.default_induction_programme, appropriate_body:)

            self
          end

        private

          attr_reader :ect_builder
        end
      end
    end
  end
end
