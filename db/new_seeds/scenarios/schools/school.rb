# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Schools
      class School
        attr_reader :name, :urn, :school, :induction_tutor, :school_cohorts, :partnerships

        def initialize(name: nil, urn: nil)
          @name = name
          @urn = urn
          @school_cohorts = {}
          @partnerships = {}
        end

        def build
          school_attributes = { name:, urn: }.compact
          @school = FactoryBot.create(:seed_school, **school_attributes)

          self
        end

        ###
        # adds a user with an induction coordinator profile for the school
        ###
        def with_an_induction_tutor(full_name: nil, email: nil)
          @induction_tutor = FactoryBot.create(:seed_user, **{ full_name:, email: }.compact)
          induction_coordinator_profile = FactoryBot.create(:seed_induction_coordinator_profile, user: induction_tutor)
          FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school:)

          self
        end

        ###
        # adds a school_cohort and a default induction programme of programme_type (:fip or :cip) for the given cohort
        ###
        def with_school_cohort_and_programme(cohort:, programme_type:)
          new_school_cohort = FactoryBot.create(:seed_school_cohort, programme_type, school:, cohort:)
          new_induction_programme = FactoryBot.create(:seed_induction_programme, programme_type, school_cohort: new_school_cohort)
          new_school_cohort.update!(default_induction_programme: new_induction_programme)
          school_cohorts[cohort.start_year] = new_school_cohort

          self
        end

        ###
        # adds a school_cohort and a default induction programme (FIP) for the given cohort
        # will also add a partnership to that cohort and induction programme
        ###
        def chosen_fip_and_partnered_in(cohort:, partnership: nil)
          tap do
            fip = NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort:, school:).build.with_programme(partnership:)
            partnerships[cohort.start_year] = fip.school_cohort.default_induction_programme.partnership
            school_cohorts[cohort.start_year] = fip.school_cohort
          end
        end

        ###
        # adds a school_cohort and a default induction programme (CIP) for the given cohort
        # will also add CIP materials to that school_cohort and induction programme
        ###
        def chosen_cip_with_materials_in(cohort:, materials: nil)
          tap do
            school_cohorts[cohort.start_year] = NewSeeds::Scenarios::SchoolCohorts::Cip
                                                  .new(cohort:, school:)
                                                  .build
                                                  .with_programme(core_induction_programme: materials)
                                                  .school_cohort
          end
        end

        ###
        # add a partnership for the cohort
        ###
        def with_partnership_in(cohort:, lead_provider: nil, delivery_partner: nil)
          traits = []
          traits << :with_lead_provider if lead_provider.nil?
          traits << :with_delivery_partner if delivery_partner.nil?

          options = {
            lead_provider:,
            delivery_partner:,
            cohort:,
            school:,
          }.compact

          partnerships[cohort.start_year] = FactoryBot.create(:seed_partnership, *traits, **options)

          self
        end

        # some accessor helpers when using simple 1 cohort setups
        def school_cohort
          school_cohorts.values.first
        end

        def induction_programme
          school_cohort&.default_induction_programme
        end

        def partnership
          partnerships.values.first
        end

      private

        def add_school_cohort(cohort:, programme_type:)
          school_cohorts[cohort.start_year] = FactoryBot.create(:seed_school_cohort, programme_type, school:, cohort:)
        end
      end
    end
  end
end
