# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class EctAfterCohortTransfer
          include ActiveSupport::Testing::TimeHelpers

          delegate :participant_profile,
                   :participant_identity,
                   :school_cohort,
                   :teacher_profile,
                   :user,
                   to: :ect_builder

          attr_reader :new_school_cohort

          # noinspection RubyParameterNamingConvention
          def initialize(school_cohort:, new_school_cohort:, full_name: nil, email: nil)
            @new_school_cohort = new_school_cohort
            @ect_builder = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:, full_name:, email:)
          end

          def build(sparsity_uplift: true, pupil_premium_uplift: true, appropriate_body: nil, **ect_builder_args)
            travel_to(2.days.ago) do
              @ect_builder.build(sparsity_uplift:, pupil_premium_uplift:, **ect_builder_args)
                          .with_validation_data
                          .with_eligibility
                          .with_induction_record(
                            induction_programme: school_cohort.default_induction_programme,
                            appropriate_body:,
                          )
            end

            @ect_builder.participant_profile.induction_records.first.update!(
              induction_status: "changed",
              end_date: Time.zone.now,
            )

            @ect_builder.add_induction_record(
              induction_programme: new_school_cohort.default_induction_programme,
              induction_status: "active",
              start_date: Time.zone.now,
            )

            self
          end

        private

          attr_reader :ect_builder
        end
      end
    end
  end
end
