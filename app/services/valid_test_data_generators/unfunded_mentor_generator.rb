# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class UnfundedMentorGenerator
    class << self
      def call(name:, cohort: Cohort.current, number: 20)
        new(name:, cohort:).call(number:)
      end
    end

    def call(number:)
      return unless partnership

      number.times { create_unfunded_mentor }
    end

  private

    attr_reader :lead_provider, :cohort

    def initialize(name:, cohort:)
      @lead_provider = ::LeadProvider.find_by!(name:)
      @cohort = cohort
    end

    def create_random_participant_identity
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name:))
      TeacherProfile.create!(user:, trn: Helpers::TrnGenerator.next)
      Identity::Create.call(user:, origin: :ecf)
    end

    def create_unfunded_mentor
      school_cohort = find_or_create_school_cohort
      participant_identity = create_random_participant_identity
      teacher_profile = participant_identity.user.teacher_profile
      ect_profile = ParticipantProfile::ECT.create!(teacher_profile:, school_cohort:, status: :active, schedule:, participant_identity:)
      mentor_profile = ParticipantProfile::Mentor.create!(teacher_profile:, school_cohort:, status: :active, schedule:, participant_identity:)
      induction_programme = school_cohort.induction_programmes.first

      Induction::Enrol.call(participant_profile: ect_profile, induction_programme:, start_date: 5.days.ago)
      Induction::Enrol.call(participant_profile: ect_profile, mentor_profile: mentor_profile, induction_programme:, start_date: Time.zone.now)
    end

    def schedule
      @schedule ||= Finance::Schedule::ECF.find_by!(cohort:, schedule_identifier: "ecf-standard-september")
    end

    def find_or_create_school_cohort
      school = partnership.school
      school_cohort = SchoolCohort.find_or_create_by!(school:, cohort:) do |sc|
        sc.induction_programme_choice = "full_induction_programme"
      end
      school.school_local_authorities.create!(local_authority: LocalAuthority.all.sample, start_year: cohort.start_year)
      Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                  programme_choice: "full_induction_programme")
      school_cohort
    end

    def partnership
      lead_provider.partnerships.joins(:school).merge!(School.eligible_or_cip_only).find_by(cohort:)
    end
  end
end
