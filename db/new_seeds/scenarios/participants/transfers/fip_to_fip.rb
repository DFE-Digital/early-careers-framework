# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToFip
          attr_reader :school_from,
                      :school_to,
                      :school_cohort_from,
                      :school_cohort_to,
                      :user,
                      :teacher_profile,
                      :participant_identity,
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
            @supplied_from_school = from_school
            @supplied_to_school = to_school
          end

        private

          def setup
            # schools with cohorts
            @school_from = @supplied_from_school || FactoryBot.create(:seed_school)
            @school_to = @supplied_to_school || FactoryBot.create(:seed_school)
            @school_cohort_from = FactoryBot.create(:seed_school_cohort, cohort: cohort(2021), school: school_from)
            @school_cohort_to = FactoryBot.create(:seed_school_cohort, cohort: cohort(2022), school: school_to)

            # a teacher to transfer
            @user = FactoryBot.create(:seed_user)
            @teacher_profile = FactoryBot.create(:seed_teacher_profile, user:, school: school_from)
            @participant_identity = FactoryBot.create(:seed_participant_identity, user:)
            @participant_profile = FactoryBot.create(:seed_ecf_participant_profile,
                                                     participant_identity:,
                                                     teacher_profile:,
                                                     school_cohort: school_cohort_from)

            # create two lead providers
            @lead_provider_from = FactoryBot.create(:seed_lead_provider)
            @lead_provider_to = FactoryBot.create(:seed_lead_provider)

            # create two delivery_partners
            @delivery_partner_from = FactoryBot.create(:seed_delivery_partner)
            @delivery_partner_to = FactoryBot.create(:seed_delivery_partner)

            # create partnerships between lead providers, delivery partners, cohorts and schools
            @partnership_from = FactoryBot.create(:seed_partnership,
                                                  cohort: cohort(2021),
                                                  school: school_from,
                                                  delivery_partner: delivery_partner_from,
                                                  lead_provider: lead_provider_from)

            @partnership_to = FactoryBot.create(:seed_partnership,
                                                cohort: cohort(2021),
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
