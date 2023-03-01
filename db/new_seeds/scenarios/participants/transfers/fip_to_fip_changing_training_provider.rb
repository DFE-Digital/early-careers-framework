# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToFipChangingTrainingProvider < FipToFip
          attr_reader :from_school, :to_school

          def initialize
            Rails.logger.info("################# seeding scenario FipToFipChangingTrainingProvider")
            super
          end

          def build
            setup

            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name} using the new school's training provider")

            FactoryBot.create(:seed_induction_record,
                              participant_profile:,
                              induction_programme: induction_programme_to)
          end
        end
      end
    end
  end
end
