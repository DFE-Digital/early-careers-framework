# frozen_string_literal: true

require "tasks/school_urn_generator"
require "tasks/trn_generator"
require "active_support/testing/time_helpers"

module ValidTestDataGenerator
  class LeadProviderPopulater
    include ActiveSupport::Testing::TimeHelpers

    class << self
      def call(name:, total_schools: 10, participants_per_school: 50)
        new(name:).call(total_schools:, participants_per_school:)
      end
    end

    def call(total_schools: 10, participants_per_school: 100)
      generate_new_schools(count: total_schools - lead_provider.schools.count) if lead_provider.schools.count < total_schools

      lead_provider.schools.order("created_at desc").limit(total_schools).each do |school|
        sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
        pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])
        find_or_create_participants(school:, number_of_participants: participants_per_school, sparsity_uplift:, pupil_premium_uplift:)
      end
    end

  private

    attr_reader :lead_provider

    def initialize(name:)
      @lead_provider = ::LeadProvider.find_or_create_by!(name:)
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:, sparsity_uplift:, pupil_premium_uplift:)
      generate_new_participants(school:, count: number_of_participants - school.ecf_participants.count, sparsity_uplift:, pupil_premium_uplift:) if school.ecf_participants.count < number_of_participants
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      while count.positive?
        status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])
        profile_type = weighted_choice(selection: %i[mentor ect], odds: [9, 1])
        count -= 1
        if profile_type == :mentor
          mentor = create_participant(school_cohort: school_cohort(school:), profile_type: :mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
          rand(0..3).times do
            create_participant(school_cohort: school_cohort(school:), profile_type: :ect, mentor_profile: mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
            count -= 1
          end
        else
          create_participant(school_cohort: school_cohort(school:), profile_type: :ect, status:, sparsity_uplift:, pupil_premium_uplift:)
        end
      end
    end

    def create_participant(school_cohort:, profile_type: :ect, mentor_profile: nil, status: "active", sparsity_uplift: false, pupil_premium_uplift: false)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name:))
      teacher_profile = TeacherProfile.create!(user:, trn: random_or_nil_trn)
      schedule = ecf_schedules.sample
      participant_identity = Identity::Create.call(user:, origin: :ecf)

      cpd_lead_provider = school_cohort.lead_provider.cpd_lead_provider
      lead_provider = cpd_lead_provider.lead_provider
      november_statement = Finance::Statement::ECF.find_by(
        cpd_lead_provider:,
        name: "November 2021",
      )

      delivery_partner = lead_provider.delivery_partners.first

      partnership = Partnership.find_or_create_by!(
        cohort: school_cohort.cohort,
        delivery_partner:,
        school: school_cohort.school,
        lead_provider:,
      )

      InductionProgramme.find_or_create_by!(
        school_cohort:,
        partnership:,
        training_programme: "full_induction_programme",
      )

      if profile_type == :ect
        profile = ParticipantProfile::ECT.create!(teacher_profile:, school_cohort:, mentor_profile:, status:, sparsity_uplift:, pupil_premium_uplift:, schedule:, participant_identity:) do |pp|
          ParticipantProfileState.create!(participant_profile: pp)
          ECFParticipantEligibility.create!(participant_profile_id: pp.id).eligible_status!
        end

        induction_programme = profile.school_cohort.induction_programmes.first
        raise unless induction_programme

        Induction::Enrol.call(participant_profile: profile, induction_programme:)

        return unless profile.active_record?

        started_declaration = travel_to profile.schedule.milestones.first.start_date + 2.days do
          RecordDeclaration.new(
            participant_id: user.tap(&:reload).id,
            course_identifier: "ecf-induction",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: "started",
          ).call
        end

        return if profile.schedule.milestones.second.start_date > Date.current

        started_declaration.make_payable!
        started_declaration.update!(
          created_at: profile.schedule.milestones.first.start_date + 1.day,
        )

        line_item = Finance::StatementLineItem.find_or_initialize_by(
          participant_declaration: started_declaration,
        )

        line_item.update!(
          statement: november_statement,
          state: started_declaration.state,
        )

        return if (profile.schedule.milestones.second.start_date + 1.day) > Time.zone.now

        RecordDeclaration.new(
          participant_id: user.tap(&:reload).id,
          course_identifier: "ecf-induction",
          declaration_date: (profile.schedule.milestones.second.start_date + 1.day).rfc3339,
          cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
          declaration_type: "retained-1",
          evidence_held: "other",
        ).call
      else
        profile = ParticipantProfile::Mentor.create!(teacher_profile:, school_cohort:, status:, sparsity_uplift:, pupil_premium_uplift:, schedule:, participant_identity:) do |pp|
          ParticipantProfileState.create!(participant_profile: pp)
          ECFParticipantEligibility.create!(participant_profile_id: pp.id).eligible_status!
        end

        induction_programme = profile.school_cohort.induction_programmes.first
        raise unless induction_programme

        Induction::Enrol.call(participant_profile: profile, induction_programme:)

        return profile unless profile.active_record?

        started_declaration = travel_to profile.schedule.milestones.first.start_date + 2.days do
          RecordDeclaration.new(
            participant_id: profile.user.tap(&:reload).id,
            course_identifier: "ecf-mentor",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: "started",
          ).call
        end

        return if profile.schedule.milestones.second.start_date > Date.current

        started_declaration.make_payable!
        started_declaration.update!(
          created_at: profile.schedule.milestones.first.start_date + 1.day,
        )

        line_item = Finance::StatementLineItem.find_or_initialize_by(
          participant_declaration: started_declaration,
        )

        line_item.update!(
          statement: november_statement,
          state: started_declaration.state,
        )

        return if (profile.schedule.milestones.second.start_date + 1.day) > Time.zone.now

        RecordDeclaration.new(
          participant_id: user.tap(&:reload).id,
          course_identifier: "ecf-mentor",
          declaration_date: (profile.schedule.milestones.second.start_date + 1.day).rfc3339,
          cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
          declaration_type: "retained-1",
          evidence_held: "other",
        ).call

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
      SchoolCohort.find_or_create_by!(school:, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn:) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      school_cohort = school_cohort(school:)
      partnership = attach_partnership_to_school(school:)
      InductionProgramme.find_or_create_by!(
        partnership:,
        training_programme: "full_induction_programme",
        school_cohort:,
      )
    end

    def attach_partnership_to_school(school:)
      Partnership.find_or_create_by!(
        school:,
        lead_provider:,
        cohort: Cohort.current,
      ) do |partnership|
        partnership.delivery_partner = DeliveryPartner.create!(name: Faker::Company.name)
        ProviderRelationship.find_or_create_by!(
          lead_provider:,
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
      FIRST_AMBITION_SEED_DATA_TIME = ("2021-08-18 13:43".."2021-08-18 13:49")

      def call(name:, total_schools: 3, participants_per_school: 3000)
        generator = new(name:)
        generator.remove_old_data(created_at: FIRST_AMBITION_SEED_DATA_TIME)
        generator.call(total_schools:, participants_per_school:)
      end
    end

    def remove_old_data(created_at:)
      lead_provider.ecf_participants.where(created_at:).each(&:destroy)
      schools = lead_provider.schools.where(created_at:)
      schools.each do |school|
        partnership = Partnership.find_by(lead_provider:, school:, cohort: Cohort.current)
        delivery_partner = partnership.delivery_partner
        provider_relationship = ProviderRelationship.find_by(lead_provider:,
                                                             cohort: Cohort.current,
                                                             delivery_partner:)
        provider_relationship.destroy!
        partnership.destroy!
        delivery_partner.destroy!
        school_cohort = SchoolCohort.find_by(school:, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
        school_cohort.ecf_participant_profiles.destroy_all
        school_cohort.destroy!
        school.destroy!
      end
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      (count / 2).times do
        status = "active"
        mentor = create_participant(school_cohort: school_cohort(school:), profile_type: :mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
        create_participant(school_cohort: school_cohort(school:), profile_type: :ect, mentor_profile: mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
      end
    end

    def random_or_nil_trn
      TRNGenerator.next
    end
  end

  class NPQLeadProviderPopulater
    class << self
      def call(name:, total_schools: 10, participants_per_school: 10)
        new(name:, participants_per_school:).call(total_schools:)
      end
    end

    def call(total_schools: 10)
      generate_new_schools(count: total_schools)
    end

  private

    attr_reader :lead_provider, :participants_per_school

    def initialize(name:, participants_per_school:)
      @lead_provider = ::NPQLeadProvider.find_or_create_by!(name:)
      @participants_per_school = participants_per_school
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:)
      generate_new_participants(school:, count: number_of_participants)
    end

    def generate_new_participants(school:, count:)
      count.times do
        create_participant(school:)
      end
    end

    def create_participant(school:)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name:))
      identity = Identity::Create.call(user:, origin: :npq)

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
        npq_course: NPQCourse.all.reject { |c| c.identifier == "npq-early-headship-coaching-offer" }.sample,
        npq_lead_provider: lead_provider,
        participant_identity: identity,
        cohort: Cohort.find_by!(start_year: 2021),
      )

      return if [true, false].sample

      accept_application(npq_application)

      return if [true, false].sample

      # skip declarations for future courses
      return if %w[
        npq-early-headship-coaching-offer
        npq-early-years-leadership
        npq-leading-literacy
      ].include?(npq_application.npq_course.identifier)

      started_declaration = create_started_declarations(npq_application)

      return if [true, false].sample

      started_declaration.make_eligible!

      return if [true, false].sample

      started_declaration.make_payable!
    end

    def accept_application(npq_application)
      AcceptNPQApplication.new(npq_application:).call
      npq_application.reload
    end

    def create_started_declarations(npq_application)
      RecordDeclaration.new(
        participant_id: npq_application.user.id,
        course_identifier: npq_application.npq_course.identifier,
        declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
        declaration_type: "started",
      ).call
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn:) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      find_or_create_participants(school:, number_of_participants: participants_per_school)
    end
  end
end
