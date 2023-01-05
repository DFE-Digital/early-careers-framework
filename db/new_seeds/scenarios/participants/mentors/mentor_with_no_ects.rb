# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentorWithNoEcts
          attr_reader :supplied_user, :user, :new_user_attributes, :mentor_profile, :participant_identity

          def initialize(user: nil, full_name: nil, email: nil)
            @supplied_user = user
            @new_user_attributes = { full_name:, email: }.compact
          end

          def build(**profile_args)
            @user = supplied_user || FactoryBot.create(:seed_user, **new_user_attributes)

            @participant_identity = user.participant_identities.first || FactoryBot.create(:seed_participant_identity, user:)

            @mentor_profile = FactoryBot.create(:seed_mentor_participant_profile, :valid, participant_identity:, **profile_args)

            self
          end

          def add_induction_record(induction_programme:)
            FactoryBot.create(
              :seed_induction_record,
              induction_programme:,
              participant_profile: mentor_profile,
              schedule: Finance::Schedule::ECF.default,
            )
          end
        end
      end
    end
  end
end
