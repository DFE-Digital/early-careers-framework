# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        # This class sets up a the background data needed to perform the
        # transfer of a participant between two schools. The subclasses
        # FipToFipChangingTrainingProvider and FipToFipKeepingOriginalTrainingProvider
        # are intended to do the actual transferring part as the induction programme
        # will vary by case
        #
        # Currently only the from_school and to_school (called school_from and
        # school_to internally to maintain sensible prefixing) are changeable. It
        # might be worth allowing some other objects to be passed in like:
        # - the user/participant identity/participant profile
        # - the delivery partners/lead providers/induction programmes
        class FipToFip
          attr_reader :school_from,
                      :school_to,
                      :school_cohort_from,
                      :school_cohort_to,
                      :participant_profile,
                      :lead_provider_from,
                      :lead_provider_to,
                      :partnership_from,
                      :partnership_to,
                      :delivery_partner_from,
                      :delivery_partner_to,
                      :induction_programme_from,
                      :induction_programme_to

          def initialize(from_school: nil, to_school: nil)
            @school_from = from_school
            @school_to = to_school
          end

          delegate :ecf_participant_eligibility,
                   :ecf_participant_validation_data,
                   :participant_identity,
                   :teacher_profile,
                   :user,
                   to: :participant_profile

        private

          def setup
            # schools with cohorts
            @school_from ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
            @school_to ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
            @school_cohort_from = FactoryBot.create(:seed_school_cohort, cohort: cohort(2022), school: school_from)
            @school_cohort_to = FactoryBot.create(:seed_school_cohort, cohort: cohort(2022), school: school_to)

            # a teacher to transfer
            @participant_profile = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: school_cohort_from)
                                                                               .build
                                                                               .chain_add_validation_data
                                                                               .chain_add_eligibility
                                                                               .participant_profile

            # create two lead providers
            @lead_provider_from = FactoryBot.create(:seed_lead_provider)
            @lead_provider_to = FactoryBot.create(:seed_lead_provider)

            # create two delivery_partners
            @delivery_partner_from = FactoryBot.create(:seed_delivery_partner)
            @delivery_partner_to = FactoryBot.create(:seed_delivery_partner)

            # create partnerships between lead providers, delivery partners, cohorts and schools
            @partnership_from = FactoryBot.create(:seed_partnership,
                                                  cohort: cohort(2022),
                                                  school: school_from,
                                                  delivery_partner: delivery_partner_from,
                                                  lead_provider: lead_provider_from)

            @partnership_to = FactoryBot.create(:seed_partnership,
                                                cohort: cohort(2022),
                                                school: school_to,
                                                delivery_partner: delivery_partner_to,
                                                lead_provider: lead_provider_to)

            # partnership induction programmes
            @induction_programme_from = FactoryBot.create(:seed_induction_programme,
                                                          :fip,
                                                          school_cohort: school_cohort_from,
                                                          partnership: partnership_to)

            @induction_programme_to = FactoryBot.create(:seed_induction_programme,
                                                        :fip,
                                                        school_cohort: school_cohort_to,
                                                        partnership: partnership_to)
          end

          def cohort(year)
            Cohort.find_by!(start_year: year)
          end
        end
      end
    end
  end
end
