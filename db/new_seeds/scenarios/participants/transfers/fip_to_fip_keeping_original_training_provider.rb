# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToFipKeepingOriginalTrainingProvider < FipToFip
          def initialize
            Rails.logger.debug("################# seeding scenario FipToFipKeepingOriginalTrainingProvider")
            super
          end

          def build
            relationship = FactoryBot.create(:seed_partnership,
                                             :relationship,
                                             cohort:,
                                             school: school_to,
                                             lead_provider: induction_programme_from.lead_provider,
                                             delivery_partner: induction_programme_from.delivery_partner)
            @induction_programme_to ||= NewSeeds::Scenarios::SchoolCohorts::Fip
                                          .new(cohort:, school: school_to)
                                          .build
                                          .add_programme(default_induction_programme: false, partnership: relationship)
            setup
            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name} while keeping their original training provider")

            create_induction_record_to
          end
        end
      end
    end
  end
end
