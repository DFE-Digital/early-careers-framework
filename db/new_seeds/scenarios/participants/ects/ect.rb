# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Ects
        class Ect
          attr_reader :new_user_attributes,
                      :participant_identity,
                      :participant_profile,
                      :school_cohort,
                      :teacher_profile,
                      :user

          delegate :ecf_participant_eligibility, :ecf_participant_validation_data, to: :participant_profile

          def initialize(school_cohort:, full_name: nil, email: nil)
            @school_cohort = school_cohort
            @new_user_attributes = { full_name:, email: }.compact
          end

          def build(**_profile_args)
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

          def add_induction_record(induction_programme:, start_date: 6.months.ago, end_date: nil, induction_status: "active", training_status: "active")
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

          def chain_add_validation_data(**args)
            add_validation_data(**args)

            self
          end

          def add_validation_data(**args)
            validation_data = { full_name: args[:full_name] || user.full_name,
                                trn: args[:trn] || teacher_profile.trn,
                                date_of_birth: args[:date_of_birth],
                                nino: args[:nino],
                                participant_profile: }

            FactoryBot.create(:seed_ecf_participant_validation_data, **validation_data.compact)
          end

          def chain_add_eligibility(**args)
            add_eligibility(**args)

            self
          end

          def add_eligibility(**args)
            eligibility_data = { qts: args[:qts],
                                 active_flags: args[:active_flags],
                                 previous_participation: args[:previous_participation],
                                 previous_induction: args[:previous_induction],
                                 no_induction: args[:no_induction],
                                 status: args[:status],
                                 reason: args[:reason],
                                 participant_profile: }

            FactoryBot.create(:seed_ecf_participant_eligibility, **eligibility_data.compact)
          end
        end
      end
    end
  end
end
