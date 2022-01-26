# frozen_string_literal: true

require "tasks/school_urn_generator"
require "tasks/trn_generator"

module ValidTestDataGenerator
  class LeadProviderPopulater
    class << self
      def call(name:, total_schools: 10, participants_per_school: 100)
        new(name: name).call(total_schools: total_schools, participants_per_school: participants_per_school)
      end
    end

    def call(total_schools: 10, participants_per_school: 100)
      generate_new_schools(count: total_schools - lead_provider.schools.count) if lead_provider.schools.count < total_schools
      lead_provider.schools.order("created_at desc").limit(total_schools).each do |school|
        sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
        pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])
        find_or_create_participants(school: school, number_of_participants: participants_per_school, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
      end
    end

  private

    attr_reader :lead_provider

    def initialize(name:)
      @lead_provider = ::LeadProvider.find_or_create_by!(name: name)
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:, sparsity_uplift:, pupil_premium_uplift:)
      generate_new_participants(school: school, count: number_of_participants - school.ecf_participants.count, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift) if school.ecf_participants.count < number_of_participants
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      while count.positive?
        status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])
        profile_type = weighted_choice(selection: %i[mentor ect], odds: [9, 1])
        count -= 1
        if profile_type == :mentor
          mentor = create_participant(school_cohort: school_cohort(school: school), profile_type: :mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
          rand(0..3).times do
            create_participant(school_cohort: school_cohort(school: school), profile_type: :ect, mentor_profile: mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
            count -= 1
          end
        else
          create_participant(school_cohort: school_cohort(school: school), profile_type: :ect, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
        end
      end
    end

    def create_participant(school_cohort:, profile_type: :ect, mentor_profile: nil, status: "active", sparsity_uplift: false, pupil_premium_uplift: false)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name: name))
      teacher_profile = TeacherProfile.create!(user: user, trn: random_or_nil_trn)
      schedule = ecf_schedules.sample
      participant_identity = Identity::Create.call(user: user, origin: :ecf)

      if profile_type == :ect
        profile = ParticipantProfile::ECT.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, mentor_profile: mentor_profile, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift, schedule: schedule, participant_identity: participant_identity) do |profile|
          ParticipantProfileState.create!(participant_profile: profile)
          ECFParticipantEligibility.create!(participant_profile_id: profile.id).eligible_status!
        end

        return unless profile.active_record?

        RecordDeclarations::Started::EarlyCareerTeacher.call(
          params: {
            participant_id: user.tap(&:reload).id,
            course_identifier: "ecf-induction",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: RecordDeclarations::ECF::STARTED,
          },
        )

        return if profile.schedule.milestones.second.start_date > Date.current

        RecordDeclarations::Retained::EarlyCareerTeacher.call(
          params: {
            participant_id: user.tap(&:reload).id,
            course_identifier: "ecf-induction",
            declaration_date: (profile.schedule.milestones.second.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: RecordDeclarations::ECF::RETAINED_ONE,
            evidence_held: "other"
          },
        )
      else
        profile = ParticipantProfile::Mentor.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift, schedule: schedule, participant_identity: participant_identity) do |profile|
          ParticipantProfileState.create!(participant_profile: profile)
          ECFParticipantEligibility.create!(participant_profile_id: profile.id).eligible_status!
        end

        return profile unless profile.active_record?

        RecordDeclarations::Started::Mentor.call(
          params: {
            participant_id: profile.user.tap(&:reload).id,
            course_identifier: "ecf-mentor",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: RecordDeclarations::ECF::STARTED,
          },
        )

        profile
      end
    end

    def ecf_schedules
      @ecf_schedules ||=
        [
          Finance::Schedule::ECF.find_by(cohort: Cohort.current, schedule_identifier: "ecf-standard-september"),
          Finance::Schedule::ECF.find_by(cohort: Cohort.current, schedule_identifier: "ecf-standard-january"),
        ]
    end

    def school_cohort(school:)
      SchoolCohort.find_or_create_by!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn: urn) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      school_cohort(school: school)
      attach_partnership_to_school(school: school)
    end

    def attach_partnership_to_school(school:)
      Partnership.find_or_create_by!(
        school: school,
        lead_provider: lead_provider,
        cohort: Cohort.current,
      ) do |partnership|
        partnership.delivery_partner = DeliveryPartner.create!(name: Faker::Company.name)
        ProviderRelationship.find_or_create_by!(
          lead_provider: lead_provider,
          cohort: Cohort.current,
          delivery_partner: partnership.delivery_partner,
        )
      end
    end

    def random_or_nil_trn
      [true, false].sample ? nil : TRNGenerator.next
    end

    def weighted_choice(selection:, odds:)
      selection.each_with_index.map { |item, index|
        [item] * odds[index]
      }.flatten.sample
    end
  end

  class AmbitionSpecificPopulater < LeadProviderPopulater
    class << self
      FIRST_AMBITION_SEED_DATA_TIME = ("2021-08-18 13:43".."2021-08-18 13:49").freeze

      def call(name:, total_schools: 3, participants_per_school: 3000)
        generator = new(name: name)
        generator.remove_old_data(created_at: FIRST_AMBITION_SEED_DATA_TIME)
        generator.call(total_schools: total_schools, participants_per_school: participants_per_school)
      end
    end

    def remove_old_data(created_at:)
      lead_provider.ecf_participants.where(created_at: created_at).each(&:destroy)
      schools = lead_provider.schools.where(created_at: created_at)
      schools.each do |school|
        partnership = Partnership.find_by(lead_provider: lead_provider, school: school, cohort: Cohort.current)
        delivery_partner = partnership.delivery_partner
        provider_relationship = ProviderRelationship.find_by(lead_provider: lead_provider,
                                                             cohort: Cohort.current,
                                                             delivery_partner: delivery_partner)
        provider_relationship.destroy!
        partnership.destroy!
        delivery_partner.destroy!
        school_cohort = SchoolCohort.find_by(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
        school_cohort.ecf_participant_profiles.destroy_all
        school_cohort.destroy!
        school.destroy!
      end
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      (count / 2).times do
        status = "active"
        mentor = create_participant(school_cohort: school_cohort(school: school), profile_type: :mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
        create_participant(school_cohort: school_cohort(school: school), profile_type: :ect, mentor_profile: mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
      end
    end

    def random_or_nil_trn
      TRNGenerator.next
    end
  end

  class NPQLeadProviderPopulater
    class << self
      def call(name:, total_schools: 10, participants_per_school: 10)
        new(name: name, participants_per_school: participants_per_school).call(total_schools: total_schools)
      end
    end

    def call(total_schools: 10)
      generate_new_schools(count: total_schools)
    end

  private

    attr_reader :lead_provider, :participants_per_school

    def initialize(name:, participants_per_school:)
      @lead_provider = ::NPQLeadProvider.find_or_create_by!(name: name)
      @participants_per_school = participants_per_school
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:)
      generate_new_participants(school: school, count: number_of_participants)
    end

    def generate_new_participants(school:, count:)
      count.times do
        create_participant(school: school)
      end
    end

    def create_participant(school:)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name: name))
      identity = Identity::Create.call(user: user, origin: :npq)

      npq_application = NPQApplication.create!(
        active_alert: "",
        date_of_birth: Date.new(1990, 1, 1),
        eligible_for_funding: true,
        funding_choice: "",
        headteacher_status: "",
        nino: "",
        school_urn: school.urn,
        teacher_reference_number: TRNGenerator.next,
        teacher_reference_number_verified: true,
        npq_course: NPQCourse.all.sample,
        npq_lead_provider: lead_provider,
        participant_identity: identity,
      )

      return if [true, false].sample

      accept_application(npq_application)

      return if [true, false].sample

      json_participant_declaration = create_started_declarations(npq_application)

      return if [true, false].sample

      deserialised_participant_declaration = JSON.parse(json_participant_declaration)
      participant_declaration = ParticipantDeclaration::NPQ
                                  .find(deserialised_participant_declaration.dig("data", "id"))
                                  .tap(&:make_eligible!)

      return if [true, false].sample

      participant_declaration.make_payable!
    end

    def accept_application(npq_application)
      NPQ::Accept.call(npq_application: npq_application)
      npq_application
    end

    def create_started_declarations(npq_application)
      RecordDeclarations::Started::NPQ.call(
        params: {
          participant_id: npq_application.user.id,
          course_identifier: npq_application.npq_course.identifier,
          declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
          cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
          declaration_type: RecordDeclarations::NPQ::STARTED,
        },
      )
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn: urn) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      find_or_create_participants(school: school, number_of_participants: participants_per_school)
    end
  end
end
