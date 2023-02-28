# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToFipKeepingOriginalTrainingProvider < FipToFip
          attr_reader :relationship,
                      :relationship_induction_programme,
                      :relationship_induction_record

          def initialize
            Rails.logger.debug("################# seeding scenario FipToFipKeepingOriginalTrainingProvider")
            super
          end

          def build
            setup

            # do a transfer:
            # * there should be a Partnershp with `relationship: true` between the new school
            #   and the lead provider of the old school
            # * create a FIP induction programme that has the new (relationship)
            #   partnership above set
            @relationship = FactoryBot.create(:seed_partnership,
                                              :relationship,
                                              cohort: cohort(2021),
                                              school: school_to,
                                              delivery_partner: delivery_partner_from, # assume we want the orig DP too
                                              lead_provider: lead_provider_from)

            @relationship_induction_programme = FactoryBot.create(:seed_induction_programme,
                                                                  :fip,
                                                                  school_cohort: school_cohort_to,
                                                                  partnership: relationship)

            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name} while keeping their original training provider")

            # enrol the participant to the new programme (aka create an induction record)
            @relationship_induction_record = FactoryBot.create(:seed_induction_record,
                                                               participant_profile:,
                                                               induction_programme: relationship_induction_programme)
          end
        end
      end
    end
  end
end
