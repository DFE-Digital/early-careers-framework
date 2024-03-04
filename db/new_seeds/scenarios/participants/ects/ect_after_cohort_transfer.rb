# frozen_string_literal: true

require_relative "ect_in_training"

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class EctAfterCohortTransfer < NewSeeds::Scenarios::Participants::Ects::EctInTraining
          include ActiveSupport::Testing::TimeHelpers

          attr_reader :new_school_cohort

          # noinspection RubyParameterNamingConvention
          def initialize(school_cohort:, new_school_cohort:, full_name: nil, email: nil)
            @new_school_cohort = new_school_cohort

            super(school_cohort:, full_name:, email:)
          end

          def build(appropriate_body: nil, **ect_builder_args)
            travel_to(2.days.ago) do
              super(appropriate_body:, **ect_builder_args)
            end

            participant_profile.induction_records.first.update!(
              induction_status: "changed",
              end_date: Time.zone.now,
            )

            add_induction_record(
              induction_programme: new_school_cohort.default_induction_programme,
              induction_status: "active",
              start_date: Time.zone.now,
            )

            self
          end
        end
      end
    end
  end
end
