# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class ECFLeadProviderPopulater
    include ActiveSupport::Testing::TimeHelpers

    class << self
      def call(name:, total_schools: 10, participants_per_school: 50, cohort: Cohort.current)
        new(name:, cohort:).call(total_schools:, participants_per_school:)
      end
    end

    def call(total_schools:, participants_per_school:)
      generate_new_schools(count: total_schools)

      lead_provider.schools.order("created_at desc").limit(total_schools).each do |school|
        sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
        pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])
        find_or_create_participants(school:, number_of_participants: participants_per_school, sparsity_uplift:, pupil_premium_uplift:)
      end
    end

  private

    attr_reader :lead_provider, :cohort

    def initialize(name:, cohort:)
      @lead_provider = ::LeadProvider.find_or_create_by!(name:)
      @cohort = cohort
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: Helpers::SchoolUrnGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:, sparsity_uplift:, pupil_premium_uplift:)
      generate_new_participants(school:, count: number_of_participants - school.ecf_participants.count, sparsity_uplift:, pupil_premium_uplift:) if school.ecf_participants.count < number_of_participants
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      while count.positive?
        status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])
        profile_type = weighted_choice(selection: %i[mentor ect], odds: [9, 1])
        participant_identity = create_random_participant_identity

        count -= 1
        if profile_type == :mentor
          mentor = create_participant(participant_identity:, school_cohort: school_cohort(school:), profile_type: :mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
          rand(0..3).times do
            create_participant(participant_identity:, school_cohort: school_cohort(school:), profile_type: :ect, mentor_profile: mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
            count -= 1
          end
        else
          create_participant(participant_identity:, school_cohort: school_cohort(school:), profile_type: :ect, status:, sparsity_uplift:, pupil_premium_uplift:)
        end
      end
    end

    def create_random_participant_identity
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name:))
      TeacherProfile.create!(user:, trn: random_or_nil_trn)
      Identity::Create.call(user:, origin: :ecf)
    end

    def create_participant(participant_identity:, school_cohort:, profile_type: :ect, mentor_profile: nil, status: "active", sparsity_uplift: false, pupil_premium_uplift: false)
      user = participant_identity.user
      teacher_profile = user.teacher_profile
      schedule = ecf_schedules.sample

      cpd_lead_provider = lead_provider.cpd_lead_provider
      statement = Finance::Statement::ECF.where(
        cpd_lead_provider:,
        cohort:,
      ).order("RANDOM()").first
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
        profile = ParticipantProfile::ECT.create!(teacher_profile:, school_cohort:, mentor_profile:, status:, sparsity_uplift:, pupil_premium_uplift:, schedule:, participant_identity:)
        ParticipantProfileState.create!(participant_profile_id: profile.id)
        ECFParticipantEligibility.create!(participant_profile_id: profile.id).eligible_status!

        induction_programme = profile.school_cohort.induction_programmes.first
        raise unless induction_programme

        Induction::Enrol.call(participant_profile: profile, induction_programme:, start_date: Time.zone.now)

        return unless profile.active_record?

        started_declaration = travel_to profile.schedule.milestones.first.start_date + rand(5.days).seconds do
          RecordDeclaration.new(
            participant_id: user.tap(&:reload).id,
            course_identifier: "ecf-induction",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: "started",
          ).call
        end
        return profile unless started_declaration

        return if profile.schedule.milestones.second.start_date > Date.current

        started_declaration.make_payable!
        started_declaration.update!(
          created_at: profile.schedule.milestones.first.start_date + 1.day,
        )

        line_item = Finance::StatementLineItem.find_or_initialize_by(
          participant_declaration: started_declaration,
        )

        line_item.update!(
          statement:,
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
        profile = ParticipantProfile::Mentor.create!(teacher_profile:, school_cohort:, status:, sparsity_uplift:, pupil_premium_uplift:, schedule:, participant_identity:)
        ParticipantProfileState.create!(participant_profile_id: profile.id)
        ECFParticipantEligibility.create!(participant_profile_id: profile.id).eligible_status!

        induction_programme = profile.school_cohort.induction_programmes.first
        raise unless induction_programme

        Induction::Enrol.call(participant_profile: profile, induction_programme:, start_date: Time.zone.now)

        return profile unless profile.active_record?

        started_declaration = travel_to profile.schedule.milestones.first.start_date + rand(5.days).seconds do
          RecordDeclaration.new(
            participant_id: profile.user.tap(&:reload).id,
            course_identifier: "ecf-mentor",
            declaration_date: (profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: profile.school_cohort.lead_provider.cpd_lead_provider,
            declaration_type: "started",
          ).call
        end
        return profile unless started_declaration

        return if profile.schedule.milestones.second.start_date > Date.current

        started_declaration.make_payable!
        started_declaration.update!(
          created_at: profile.schedule.milestones.first.start_date + 1.day,
        )

        line_item = Finance::StatementLineItem.find_or_initialize_by(
          participant_declaration: started_declaration,
        )

        line_item.update!(
          statement:,
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
          Finance::Schedule::ECF.find_by(cohort:, schedule_identifier: "ecf-standard-september"),
          Finance::Schedule::ECF.find_by(cohort:, schedule_identifier: "ecf-standard-january"),
        ]
    end

    def school_cohort(school:)
      SchoolCohort.find_by(school:, cohort:) ||
        SchoolCohort.create!(school:, cohort:, induction_programme_choice: "full_induction_programme")
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn:) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
        s.primary_contact_email = "school-info-#{s.urn}@example.com"
        s.school_status_code = 1
        s.school_type_code = 1
        s.administrative_district_code = "E123"
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

    def random_or_nil_trn
      [true, false].sample ? nil : Helpers::TrnGenerator.next
    end

    def weighted_choice(selection:, odds:)
      selection.each_with_index.map { |item, index|
        [item] * odds[index]
      }.flatten.sample
    end
  end

  class AmbitionSpecificPopulater < ECFLeadProviderPopulater
    class << self
      FIRST_AMBITION_SEED_DATA_TIME = ("2022-08-18 13:43".."2022-08-18 13:49")

      def call(name:, total_schools: 3, participants_per_school: 3000, cohort: Cohort.current)
        generator = new(name:, cohort:)

        generator.remove_old_data(created_at: FIRST_AMBITION_SEED_DATA_TIME)
        generator.call(total_schools:, participants_per_school:)
      end
    end

    def remove_old_data(created_at:)
      lead_provider.ecf_participants.where(created_at:).find_each(&:destroy)
      schools = lead_provider.schools.where(created_at:)
      schools.each do |school|
        partnership = Partnership.find_by(lead_provider:, school:, cohort:)
        delivery_partner = partnership.delivery_partner
        provider_relationship = ProviderRelationship.find_by(lead_provider:,
                                                             cohort:,
                                                             delivery_partner:)
        provider_relationship.destroy!
        partnership.destroy!
        delivery_partner.destroy!
        school_cohort = SchoolCohort.find_by(school:, cohort:, induction_programme_choice: "full_induction_programme")
        school_cohort.ecf_participant_profiles.destroy_all
        school_cohort.destroy!
        school.destroy!
      end
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      (count / 2).times do
        status = "active"
        mentor = create_participant(participant_identity: create_random_participant_identity, school_cohort: school_cohort(school:), profile_type: :mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
        create_participant(participant_identity: create_random_participant_identity, school_cohort: school_cohort(school:), profile_type: :ect, mentor_profile: mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
      end
    end

    def random_or_nil_trn
      Helpers::TrnGenerator.next
    end
  end
end
