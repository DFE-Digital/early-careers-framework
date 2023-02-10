# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class Ect
          attr_reader :user, :new_user_attributes, :participant_profile, :participant_identity, :teacher_profile, :school_cohort

          def initialize(school_cohort:, full_name: nil, email: nil)
            @school_cohort = school_cohort
            @new_user_attributes = { full_name:, email: }.compact
          end

          def build(**profile_args)
            @user = FactoryBot.create(:seed_user, **new_user_attributes)

            @participant_identity = FactoryBot.create(:seed_participant_identity, user:)

            @teacher_profile = FactoryBot.create(:seed_teacher_profile, user:, school: school_cohort.school)

            @participant_profile = FactoryBot.create(:seed_ect_participant_profile, participant_identity:, teacher_profile:, school_cohort:)

            self
          end

          def chain_add_induction_record(**induction_args)
            add_induction_record(**induction_args)
            self
          end

          def add_induction_record(induction_programme:, start_date:, end_date:, induction_status: "active", training_status: "active")
            FactoryBot.create(
              :seed_induction_record,
              induction_programme:,
              participant_profile:,
              schedule: Finance::Schedule::ECF.default_for(cohort: induction_programme.cohort),
              start_date:,
              end_date:,
              induction_status:,
              training_status:,
            )
          end
        end
      end
    end
  end
end
