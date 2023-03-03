# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        # This class sets up a the background data needed to perform the
        # transfer of a participant between two schools. The subclasses
        # FipToFipChangingTrainingProvider and FipToFipKeepingOriginalTrainingProvider
        # are intended to do the actual transferring part as the induction programme
        # will vary by case
        #
        # Currently only the from_school and to_school (called school_from and
        # school_to internally to maintain sensible prefixing) are changeable. It
        # might be worth allowing some other objects to be passed in like:
        # - the user/participant identity/participant profile
        # - the delivery partners/lead providers/induction programmes
        class FipToFip
          COHORT_START_YEAR = 2022

          attr_reader :participant_profile,
                      :induction_programme_to

          def initialize(from_school: nil, to_school: nil)
            @school_from = from_school
            @school_to = to_school
          end

          def induction_programme_from
            @induction_programme_from ||= NewSeeds::Scenarios::SchoolCohorts::Fip
                                            .new(cohort:, school: school_from)
                                            .build
                                            .with_programme
                                            .school_cohort
                                            .default_induction_programme
          end

        private

          def cohort
            @cohort ||= Cohort.find_by!(start_year: COHORT_START_YEAR)
          end

          def create_induction_record_to
            FactoryBot.create(:seed_induction_record,
                              induction_programme: induction_programme_to,
                              participant_profile:,
                              preferred_identity: FactoryBot.create(:seed_participant_identity, user: participant_profile.user),
                              schedule: Finance::Schedule::ECF.default_for(cohort: induction_programme_to.cohort),
                              start_date: 6.months.ago + 10.days,
                              school_transfer: true,
                              induction_status: :active,
                              training_status: :active)
          end

          def email
            @email ||= "participant-identity-#{SecureRandom.hex(4)}@example.com"
          end

          def mentor_profile
            participant_profile.latest_induction_record.mentor_profile
          end

          def school_cohort_from
            induction_programme_from.school_cohort
          end

          def school_cohort_to
            induction_programme_to.school_cohort
          end

          def school_from
            @school_from ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
          end

          def school_to
            @school_to ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
          end

          def setup
            @induction_programme_to ||= NewSeeds::Scenarios::SchoolCohorts::Fip
                                          .new(cohort:, school: school_to)
                                          .build
                                          .with_programme
                                          .school_cohort
                                          .default_induction_programme
            # a teacher to transfer
            @participant_profile = NewSeeds::Scenarios::Participants::Ects::Ect
                                     .new(school_cohort: school_cohort_from)
                                     .build
                                     .with_validation_data
                                     .with_eligibility
                                     .with_induction_record(induction_programme: induction_programme_from,
                                                            induction_status: :leaving,
                                                            end_date: 6.months.ago + 10.days)
                                     .participant_profile
          end

          def start_date
            participant_profile.latest_induction_record.start_date + 10.days
          end
        end
      end
    end
  end
end
