# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentoringMultipleEctsWithSameProvider
          attr_accessor :mentor,
                        :mentees,
                        :school,
                        :school_cohort,
                        :partnership,
                        :delivery_partner,
                        :lead_provider,
                        :induction_programme

          def initialize(school: nil, mentor: nil, lead_provider: nil, delivery_partner: nil)
            Rails.logger.info("################# seeding scenario MentoringMultipleEctsWithSameProvider")
            @school            = school
            @mentor            = mentor
            @lead_provider     = lead_provider
            @delivery_partner  = delivery_partner
          end

          def build(number_of_mentees: Random.rand(1..4), with_eligibility: true, with_validation_data: true)
            # set up school with cohort, lead provider, delivery partner and induction programme
            # we'll probably be doing a lot of this, might make sense to move it somewhere communal
            @school ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
            @lead_provider ||= FactoryBot.create(:seed_lead_provider)
            @delivery_partner ||= FactoryBot.create(:seed_delivery_partner)

            cohort = cohort(2022)
            @school_cohort = @school.school_cohorts.find_by(cohort:) || FactoryBot.create(:seed_school_cohort, cohort:, school:)

            @partnership = FactoryBot.create(:seed_partnership,
                                             cohort:,
                                             school:,
                                             delivery_partner:,
                                             lead_provider:,
                                             relationship: Partnership.exists?(cohort:, school:))

            @induction_programme = NewSeeds::Scenarios::InductionProgrammes::Fip
                                     .new(school_cohort:)
                                     .build
                                     .with_partnership(partnership:)
                                     .induction_programme

            @mentor ||= build_mentor

            add_mentees(number_of_mentees, with_eligibility:, with_validation_data:)
          end

        private

          def build_mentor
            NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
              .new(school_cohort:)
              .build
              .with_induction_record(induction_programme:)
              .with_validation_data
              .participant_profile
          end

          def build_mentee(with_eligibility:, with_validation_data:)
            NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:).build.tap do |ect|
              ect.with_eligibility if with_eligibility
              ect.with_validation_data if with_validation_data
              ect.with_induction_record(induction_programme:, mentor_profile: mentor)
            end
          end

          def add_mentees(number, with_eligibility:, with_validation_data:)
            raise(StandardError, "A mentor is required before mentees are added") if @mentor.blank?

            Rails.logger.info("seeding #{number} mentees with eligibility: #{with_eligibility}, validation_data: #{with_validation_data}")
            @mentees = number.times.map do
              build_mentee(with_eligibility:, with_validation_data:).participant_profile.tap do |mentee|
                Rails.logger.info("seeded induction record where #{mentor.full_name} is mentoring #{mentee.full_name}")
              end
            end

            self
          end

          def cohort(year)
            Cohort.find_by!(start_year: year)
          end
        end
      end
    end
  end
end
