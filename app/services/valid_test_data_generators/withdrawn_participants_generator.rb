# frozen_string_literal: true

require "active_support/testing/time_helpers"
require Rails.root.join("db/new_seeds/scenarios/schools/school.rb")
require Rails.root.join("app/services/withdraw_participant.rb")

module ValidTestDataGenerators
  class WithdrawnParticipantsGenerator
    include ActiveSupport::Testing::TimeHelpers

    PROGRAMME_TYPES = %i[fip cip design_our_own school_funded_fip].freeze

    class << self
      def call(name:, cohort: Cohort.current, count: 20)
        new(name:, cohort:).call(count:)
      end
    end

    def call(count:)
      count.times do
        PROGRAMME_TYPES.each do |programme_type|
          create_ect_partially_trained_withdrawn(programme_type:)
          create_mentor_partially_trained_withdrawn(programme_type:)
        end
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

    def create_ect_partially_trained_withdrawn(programme_type:)
      participant_profile = create_participant(klass: ParticipantProfile::ECT, programme_type:).participant_profile

      course_identifier = "ecf-induction"
      create_declaration(participant_profile:, course_identifier:)

      WithdrawParticipant.new(
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        participant_id: participant_profile.user_id,
        reason: "school-left-fip",
        course_identifier:,
      ).call
    end

    def create_mentor_partially_trained_withdrawn(programme_type:)
      participant_profile = create_participant(klass: ParticipantProfile::Mentor, programme_type:).participant_profile

      course_identifier = "ecf-mentor"
      create_declaration(participant_profile:, course_identifier:)

      WithdrawParticipant.new(
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        participant_id: participant_profile.user_id,
        reason: "school-left-fip",
        course_identifier:,
      ).call
    end

    def create_declaration(participant_profile:, course_identifier:)
      declaration_date = participant_profile.schedule.milestones.find_by(declaration_type: "started").start_date.rfc3339

      RecordDeclaration.new(
        participant_id: participant_profile.user_id,
        course_identifier:,
        declaration_date:,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        declaration_type: "started",
        evidence_held: "other",
      ).call
    end

    def create_school(cohort:, programme_type:)
      ::NewSeeds::Scenarios::Schools::School
      .new(name: "Programme type changes - #{lead_provider.name} - #{cohort.start_year} - #{programme_type}")
      .build
      .with_partnership_in(cohort:, delivery_partner: DeliveryPartner.create!(name: Faker::Company.name), lead_provider:)
      .with_an_induction_tutor(full_name: "Programme type changes SIT - #{lead_provider.name} - #{cohort.start_year} - #{programme_type}", email: Faker::Internet.email)
      .with_school_cohort_and_programme(cohort:, programme_type:)
    end

    def create_participant(klass:, programme_type:)
      school = create_school(cohort:, programme_type:)
      school_cohort = school.school.school_cohorts.find_by(cohort:)
      induction_programme = school.induction_programme
      induction_programme.update!(partnership_id: school.partnership.id)
      participant_identity = create_random_participant_identity
      teacher_profile = participant_identity.user.teacher_profile
      schedule = Finance::Schedule.find_by(
        schedule_identifier: "ecf-standard-september",
        cohort:,
      )
      participant_profile = klass.create!(teacher_profile:, school_cohort:, status: :active, schedule:, participant_identity:)
      ParticipantProfileState.create!(participant_profile:)
      ECFParticipantEligibility.create!(participant_profile:).eligible_status!

      Induction::Enrol.call(participant_profile:, induction_programme:, start_date: Time.zone.now)
    end
  end
end
