# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToFipChangingTrainingProvider < FipToFip
          def initialize(lead_provider_from: nil, lead_provider_to: nil)
            Rails.logger.info("################# seeding scenario FipToFipChangingTrainingProvider")
            super
          end

          def build
            setup
            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name} using the new school's training provider")

            create_induction_record_to
          end
        end
      end
    end
  end
end
