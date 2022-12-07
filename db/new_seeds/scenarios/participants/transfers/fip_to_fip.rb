# frozen_string_literal: true

module Participants
  module Transfers
    class FipToFip
      attr_reader :from_school, :to_school

      def initialize(from_school: nil, to_school: nil)
        Rails.logger.debug("################# seeding FipToFip")

        @from_school = from_school
        @to_school = to_school
      end

      def setup
        # schools with cohorts
        school_1 = from_school || FactoryBot.create(:seed_school)
        school_2 = to_school || FactoryBot.create(:seed_school)
        school_cohort_1 = FactoryBot.create(:seed_school_cohort, cohort: cohort(2021), school: school_1)
        school_cohort_2 = FactoryBot.create(:seed_school_cohort, cohort: cohort(2022), school: school_2)

        # a teacher to transfer
        user = FactoryBot.create(:seed_user)
        teacher_profile = FactoryBot.create(:seed_teacher_profile, user:, school: school_1)
        participant_identity = FactoryBot.create(:seed_participant_identity, user:)
        participant_profile = FactoryBot.create(:seed_ecf_participant_profile,
                                                participant_identity:,
                                                teacher_profile:,
                                                school_cohort: school_cohort_1)

        # create two lead providers
        lead_provider_1 = FactoryBot.create(:seed_lead_provider)
        lead_provider_2 = FactoryBot.create(:seed_lead_provider)

        # create two delivery_partners
        delivery_partner_1 = FactoryBot.create(:seed_delivery_partner)
        delivery_partner_2 = FactoryBot.create(:seed_delivery_partner)

        # create partnerships between lead providers, delivery partners, cohorts and schools
        partnership_1 = FactoryBot.create(:seed_partnership,
                                          cohort: cohort(2021),
                                          school: school_1,
                                          delivery_partner: delivery_partner_1,
                                          lead_provider: lead_provider_1)

        partnership_2 = FactoryBot.create(:seed_partnership,
                                          cohort: cohort(2021),
                                          school: school_2,
                                          delivery_partner: delivery_partner_2,
                                          lead_provider: lead_provider_2)

        # partnership induction programmes
        _induction_programme_1 = FactoryBot.create(:seed_induction_programme,
                                                   :fip,
                                                   school_cohort: school_cohort_1,
                                                   partnership: partnership_1)

        _induction_programme_2 = FactoryBot.create(:seed_induction_programme,
                                                   :fip,
                                                   school_cohort: school_cohort_2,
                                                   partnership: partnership_2)

        # do a transfer:
        # * there should be a Partnershp with `relationship: true` between the new school
        #   and the lead provider of the old school
        # * create a FIP induction programme that has the new (relationship)
        #   partnership above set
        partnership_t = FactoryBot.create(:seed_partnership,
                                          :relationship,
                                          cohort: cohort(2021),
                                          school: school_2,
                                          delivery_partner: delivery_partner_1, # assume we want the orig DP too
                                          lead_provider: lead_provider_1)

        induction_programme_t = FactoryBot.create(:seed_induction_programme,
                                                  :fip,
                                                  school_cohort: school_cohort_2,
                                                  partnership: partnership_t)

        # enrol the participant to the new programme (aka create an induction record)
        _induction_record_t = FactoryBot.create(:seed_induction_record,
                                                participant_profile:,
                                                induction_programme: induction_programme_t)
      end

      def cohort(year)
        Cohort.find_by!(start_year: year)
      end
    end
  end
end
