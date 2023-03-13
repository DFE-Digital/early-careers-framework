# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentorWithNoEcts
          attr_reader :participant_profile

          def initialize(school_cohort: nil, full_name: nil, email: nil, teacher_profile: nil, participant_identity: nil)
            @school_cohort = school_cohort
            @new_user_attributes = { full_name:, email: }.compact
            @supplied_teacher_profile = teacher_profile
            @supplied_participant_identity = participant_identity
          end

          def build(**profile_args)
            school = school_cohort.school
            @user = @supplied_participant_identity&.user || FactoryBot.create(:seed_user, **new_user_attributes)
            @teacher_profile = @supplied_teacher_profile || FactoryBot.create(:seed_teacher_profile, user:, school:)
            @participant_identity = @supplied_participant_identity || FactoryBot.create(:seed_participant_identity, user:)
            @participant_profile = FactoryBot.create(:seed_mentor_participant_profile,
                                                     participant_identity:,
                                                     school_cohort:,
                                                     teacher_profile:,
                                                     **profile_args)

            @participant_profile.school_mentors << FactoryBot.create(:seed_school_mentor,
                                                                     school:,
                                                                     participant_profile:,
                                                                     preferred_identity: participant_identity)
            self
          end

          def with_induction_record(**induction_args)
            add_induction_record(**induction_args)
            self
          end

          def add_induction_record(induction_programme:, start_date: 6.months.ago, end_date: nil,
                                   induction_status: "active", training_status: "active", preferred_identity: nil,
                                   appropriate_body: nil)
            preferred_identity ||= participant_profile.participant_identity

            FactoryBot.create(
              :seed_induction_record,
              induction_programme:,
              participant_profile:,
              preferred_identity:,
              schedule: Finance::Schedule::ECF.default_for(cohort: induction_programme.cohort),
              start_date:,
              end_date:,
              induction_status:,
              training_status:,
              appropriate_body:,
            )
          end

          def with_validation_data(**args)
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

          def with_eligibility(**args)
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

          private

          attr_reader :new_user_attributes,
                      :school_cohort,
                      :teacher_profile,
                      :participant_identity,
                      :user
        end
      end
    end
  end
end
