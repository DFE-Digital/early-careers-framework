# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Transfers
        class FipToCip
          COHORT_START_YEAR = 2022

          attr_reader :participant_profile,
                      :induction_programme_to,
                      :induction_programme_from

          def initialize(from_school: nil, to_school: nil, lead_provider_from: nil)
            @school_from = from_school
            @school_to = to_school
            @supplied_lead_provider_from = lead_provider_from
          end

          def build
            setup
            Rails.logger.info("seeded transfer of #{participant_profile.full_name} from #{school_from.name} to #{school_to.name}")
            create_induction_record_to
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

          def lead_provider_from
            @lead_provider_from ||= @supplied_lead_provider_from || FactoryBot.create(:seed_lead_provider)
          end

          def setup
            @induction_programme_from ||= NewSeeds::Scenarios::Schools::School
                                          .new
                                          .build
                                          .with_partnership_in(cohort:, lead_provider: lead_provider_from)
                                          .chosen_fip_and_partnered_in(cohort:)
                                          .induction_programme
            @induction_programme_to ||= NewSeeds::Scenarios::Schools::School
                                            .new
                                            .build
                                            .chosen_cip_with_materials_in(cohort:)
                                            .induction_programme
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
