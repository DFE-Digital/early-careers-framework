# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentoringMultipleEctsWithSameProvider
          Person = Struct.new(
            :user,
            :teacher_profile,
            :participant_profile,
            :participant_identity,
            :ecf_participant_validation_data,
            :ecf_participant_eligibility,
            keyword_init: true,
          )

          attr_accessor :mentor,
                        :mentees,
                        :mentee_induction_records,
                        :school,
                        :number,
                        :user,
                        :school_cohort,
                        :partnership,
                        :delivery_partner,
                        :lead_provider,
                        :induction_programme

          def initialize(school: nil, mentor: nil, lead_provider: nil, delivery_partner: nil, number: 2)
            Rails.logger.info("################# seeding scenario MentoringMultipleEctsWithSameProvider")
            @school           = school
            @mentor           = mentor
            @number           = number
            @lead_provider    = lead_provider
            @delivery_partner = delivery_partner
          end

          def build
            # set up school with cohort, lead provider, delivery partner and induction programme

            # we'll probably be doing a lot of this, might make sense to move it somewhere communal
            @school ||= FactoryBot.create(:seed_school, :with_induction_coordinator)
            @lead_provider ||= FactoryBot.create(:seed_lead_provider)
            @delivery_partner ||= FactoryBot.create(:seed_delivery_partner)

            @school_cohort = @school.school_cohorts.find_by(cohort: cohort(2022)) || FactoryBot.create(:seed_school_cohort, cohort: cohort(2022), school:)

            @partnership = FactoryBot.create(:seed_partnership,
                                             cohort: cohort(2022),
                                             school:,
                                             delivery_partner:,
                                             lead_provider:)

            @induction_programme = FactoryBot.create(:seed_induction_programme,
                                                     :fip,
                                                     school_cohort:,
                                                     partnership:)

            # set up mentor
            @mentor ||= build_mentor

            # set up ECTs
            @mentees = number.times.map { build_mentee }

            # assign ECTs to mentor
            @mentee_induction_records = mentees.each do |mentee|
              FactoryBot.create(:seed_induction_record,
                                participant_profile: mentee.participant_profile,
                                mentor_profile: mentor.participant_profile,
                                induction_programme:)

              Rails.logger.info("seeded induction record where #{mentor.user.full_name} is mentoring #{mentee.user.full_name}")
            end

            self
          end

          def build_mentor
            build_person(mentor: true)
          end

          def build_mentee
            build_person(mentor: false)
          end

        private

          def cohort(year)
            Cohort.find_by!(start_year: year)
          end

          def build_person(mentor: false)
            scenario = if mentor
                         NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
                       else
                         NewSeeds::Scenarios::Participants::Ects::Ect
                       end
            participant = scenario.new(school_cohort:)
                                  .build
                                  .chain_add_validation_data
                                  .chain_add_eligibility

            Person.new(
              user: participant.user,
              teacher_profile: participant.teacher_profile,
              participant_identity: participant.participant_identity,
              participant_profile: participant.participant_profile,
              ecf_participant_validation_data: participant.ecf_participant_validation_data,
              ecf_participant_eligibility: participant.ecf_participant_eligibility,
            )
          end
        end
      end
    end
  end
end
