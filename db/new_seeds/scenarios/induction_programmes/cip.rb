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

        def initialize(school_cohort:)
          @school_cohort = school_cohort
        end

        def build(default_induction_programme: true)
          @induction_programme = FactoryBot.create(:seed_induction_programme, :cip, school_cohort:)
          set_default_induction_programme! if default_induction_programme

          self
        end

        def with_core_induction_programme(core_induction_programme: nil, default_core_induction_programme: true)
          core_induction_programme ||= FactoryBot.create(:seed_core_induction_programme)
          induction_programme.update!(core_induction_programme:)
          set_default_core_induction_programme! if default_core_induction_programme

          self
        end

      private

        attr_reader :school_cohort

        delegate :core_induction_programme, to: :induction_programme

        def set_default_induction_programme!
          school_cohort.update!(default_induction_programme: induction_programme)
        end

        def set_default_core_induction_programme!
          school_cohort.update!(core_induction_programme:)
        end
      end
    end
  end
end
