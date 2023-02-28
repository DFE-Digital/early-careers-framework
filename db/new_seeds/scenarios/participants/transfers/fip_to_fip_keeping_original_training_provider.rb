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
            setup

            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name} while keeping their original training provider")

            @induction_programme_to = Induction::TransferAndContinueExistingFip
                                        .call(school_cohort: school_cohort_to,
                                              participant_profile:,
                                              email:,
                                              start_date:,
                                              mentor_profile:)
                                        .induction_programme
          end
        end
      end
    end
  end
end
