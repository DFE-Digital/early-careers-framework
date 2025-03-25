# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class ClosingCohortGenerator
    COHORT_TO_CLOSE = 2022
    ECT_DECLARATION_TYPES = %w[started retained-1 retained-2 retained-3 retained-4 completed].freeze
    MENTOR_DECLARATION_TYPES = %w[started completed].freeze
    DECLARATION_STATES = %w[eligible payable paid].freeze
    SCHEDULE_IDENTIFIERS = %w[
      ecf-standard-september
      ecf-standard-january
      ecf-standard-april
      ecf-extended-september
      ecf-extended-january
      ecf-extended-april
      ecf-reduced-april
    ].freeze

    class << self
      def call(name:, cohort: Cohort.current, number: 20)
        new(name:, cohort:).call(number:)
      end
    end

    def call(number:)
      return unless cohort.start_year == COHORT_TO_CLOSE

      cohort.freeze_payments!

      number.times do
        schedules.each do |schedule|
          create_ect_partially_trained_migrated(schedule:)
          create_ect_completed_not_migrated(schedule:)
          create_mentor_partially_trained_completed_not_migrated(schedule:)
          create_mentor_completed_not_migrated(schedule:)
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

    def create_school_cohort(school:, cohort:)
      school_cohort = SchoolCohort.find_or_create_by!(school:, cohort:) do |sc|
        sc.induction_programme_choice = "full_induction_programme"
      end
      school.school_local_authorities.create!(local_authority: LocalAuthority.all.sample, start_year: cohort.start_year)
      Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                  programme_choice: "full_induction_programme")
      school_cohort
    end

    def create_ect_partially_trained_migrated(schedule:)
      participant_profile = create_participant(klass: ParticipantProfile::ECT, schedule:).participant_profile

      course_identifier = "ecf-induction"
      declaration_type = ECT_DECLARATION_TYPES.excluding("completed").sample
      create_declaration(participant_profile:, course_identifier:, declaration_type:)

      migrate_to_2024(participant_profile:, course_identifier:)
    end

    def create_ect_completed_not_migrated(schedule:)
      induction_completion_date = Faker::Number.between(from: 50, to: 100).days.ago
      participant_profile = create_participant(klass: ParticipantProfile::ECT, schedule:, induction_completion_date:).participant_profile

      course_identifier = "ecf-induction"
      ECT_DECLARATION_TYPES.each do |declaration_type|
        create_declaration(participant_profile:, course_identifier:, declaration_type:)
      end
    end

    def create_mentor_partially_trained_completed_not_migrated(schedule:)
      mentor_completion_date = Faker::Number.between(from: 50, to: 100).days.ago
      mentor_completion_reason = ParticipantProfile::Mentor.mentor_completion_reasons.keys.sample
      participant_profile = create_participant(klass: ParticipantProfile::Mentor, schedule:, mentor_completion_date:, mentor_completion_reason:).participant_profile

      course_identifier = "ecf-mentor"
      declaration_type = MENTOR_DECLARATION_TYPES.excluding("completed").sample
      create_declaration(participant_profile:, course_identifier:, declaration_type:)
    end

    def create_mentor_completed_not_migrated(schedule:)
      mentor_completion_date = Faker::Number.between(from: 50, to: 100).days.ago
      mentor_completion_reason = ParticipantProfile::Mentor.mentor_completion_reasons.keys.sample
      participant_profile = create_participant(klass: ParticipantProfile::Mentor, schedule:, mentor_completion_date:, mentor_completion_reason:).participant_profile

      course_identifier = "ecf-mentor"
      MENTOR_DECLARATION_TYPES.each do |declaration_type|
        create_declaration(participant_profile:, course_identifier:, declaration_type:)
      end
    end

    def create_declaration(participant_profile:, course_identifier:, declaration_type:)
      declaration_date = participant_profile.schedule.milestones.find_by(declaration_type:).start_date.rfc3339

      # Un-freeze cohort while we create a declaration
      cohort.update!(payments_frozen_at: nil)

      declaration = RecordDeclaration.new(
        participant_id: participant_profile.user_id,
        course_identifier:,
        declaration_date:,
        cpd_lead_provider: participant_profile.lead_provider.cpd_lead_provider,
        declaration_type:,
        evidence_held: evidence_held(declaration_type:),
      ).call

      declaration.update!(state: DECLARATION_STATES.sample)

      # Re-freeze cohort after creating a declaration
      cohort.freeze_payments!

      declaration
    end

    def create_participant(klass:, schedule:, induction_completion_date: nil, mentor_completion_date: nil, mentor_completion_reason: nil)
      partnership = lead_provider.partnerships.joins(:school).merge!(School.eligible_or_cip_only).find_by(cohort:)
      school_cohort = create_school_cohort(school: partnership.school, cohort:)
      participant_identity = create_random_participant_identity
      teacher_profile = participant_identity.user.teacher_profile
      participant_profile = klass.create!(teacher_profile:, school_cohort:, status: :active, schedule:, participant_identity:, induction_completion_date:, mentor_completion_date:, mentor_completion_reason:)
      ParticipantProfileState.create!(participant_profile:)
      ECFParticipantEligibility.create!(participant_profile:).eligible_status!
      Induction::Enrol.call(participant_profile:, induction_programme: school_cohort.induction_programmes.first, start_date: Time.zone.now)
    end

    def migrate_to_2024(participant_profile:, course_identifier:)
      cohort = Cohort.find_by(start_year: 2024)
      create_partnership(participant_profile:, cohort:)

      service = ChangeSchedule.new(
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        participant_id: participant_profile.user_id,
        course_identifier:,
        schedule_identifier: participant_profile.schedule.schedule_identifier,
        cohort: 2024,
        allow_change_to_from_frozen_cohort: true,
      )

      service.call
    end

    def create_partnership(participant_profile:, cohort:)
      school = participant_profile.school_cohort.school
      create_school_cohort(school:, cohort:)

      Partnership.find_or_create_by!(
        school:,
        lead_provider:,
        cohort:,
      ) do |partnership|
        partnership.delivery_partner = DeliveryPartner.create!(name: Faker::Company.name)
        ProviderRelationship.find_or_create_by!(
          lead_provider:,
          cohort:,
          delivery_partner: partnership.delivery_partner,
        )
      end
    end

    def evidence_held(declaration_type:)
      if cohort.detailed_evidence_types?
        case declaration_type
        when "started", "retained-1", "retained-3", "retained-4", "extended-1", "extended-2", "extended-3"
          "other"
        else
          "75-percent-engagement-met"
        end
      elsif declaration_type != "started"
        "other"
      end
    end

    def schedules
      @schedules = Finance::Schedule.where(
        schedule_identifier: SCHEDULE_IDENTIFIERS,
        cohort: Cohort.find_by(start_year: 2022),
      )
    end
  end
end
