# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module InductionProgrammes
      # Creates a CIP induction programme to the given school cohort.
      # Also links it to the provided core induction programme or a fresh new one.
      # Optionally sets it as the default induction programme of the school cohort. Default: true.
      # Optionally sets the core induction programme as the default for the school cohort. Default: true.
      class Cip
        attr_accessor :induction_programme

        def initialize(school_cohort:, core_induction_programme: nil)
          @school_cohort = school_cohort
          @core_induction_programme = core_induction_programme
        end

        def build(default_induction_programme: true, default_core_induction_programme: true)
          tap do
            @induction_programme = FactoryBot.create(:seed_induction_programme,
                                                     :cip,
                                                     school_cohort:,
                                                     core_induction_programme:)
            set_defaults!(default_induction_programme:, default_core_induction_programme:)
          end
        end

      private

        attr_reader :school_cohort

        def core_induction_programme
          return if with_no_core_induction_programme?

          @core_induction_programme ||= FactoryBot.create(:seed_core_induction_programme)
        end

        def set_defaults!(default_induction_programme:, default_core_induction_programme:)
          defaults = default_core_induction_programme ? { core_induction_programme: } : {}
          defaults.merge!(default_induction_programme: induction_programme) if default_induction_programme
          school_cohort.update!(**defaults) if defaults.present?
        end

        def with_no_core_induction_programme?
          @with_no_core_induction_programme ||= @core_induction_programme == :none
        end
      end
    end
  end
end
