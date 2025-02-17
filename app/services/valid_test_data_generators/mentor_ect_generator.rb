# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class MentorECTGenerator
    class << self
      def call(name:, cohort: Cohort.current, number: 20)
        new(name:, cohort:).call(number:)
      end
    end

    def call(number:)
      return unless partnership

      number.times do
        create_participant(klass: ParticipantProfile::ECT)
        create_participant(klass: ParticipantProfile::Mentor)
      end
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

    def create_participant(klass:)
      school_cohort = find_or_create_school_cohort
      participant_identity = create_random_participant_identity
      teacher_profile = participant_identity.user.teacher_profile
      participant_profile = klass.create!(teacher_profile:, school_cohort:, status: :active, schedule:, participant_identity:)
      ParticipantProfileState.create!(participant_profile:)
      ECFParticipantEligibility.create!(participant_profile:).eligible_status!
      Induction::Enrol.call(participant_profile:, induction_programme: school_cohort.induction_programmes.first)
    end

    def schedule
      @schedule ||= Finance::Schedule::ECF.find_by!(cohort:, schedule_identifier: "ecf-standard-september")
    end

    def find_or_create_school_cohort
      school = partnership.school
      school_cohort = SchoolCohort.find_or_create_by!(school:, cohort:, induction_programme_choice: "full_induction_programme")
      InductionProgramme.find_or_create_by!(school_cohort:, partnership:, training_programme: "full_induction_programme")
      school_cohort
    end

    def partnership
      lead_provider.partnerships.find_by(cohort:)
    end
  end
end
