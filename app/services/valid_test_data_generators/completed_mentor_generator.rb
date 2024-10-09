# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class CompletedMentorGenerator
    include ActiveSupport::Testing::TimeHelpers

    class << self
      def call(name:, cohort: Cohort.current, total_completed_mentors: 30)
        new(name:, cohort:).call(total_completed_mentors:)
      end
    end

    def call(total_completed_mentors:)
      school = create_fip_school_with_cohort(urn: Helpers::SchoolUrnGenerator.next)

      sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
      pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])

      total_completed_mentors.times do
        mentor = create_mentor(school:, sparsity_uplift:, pupil_premium_uplift:)

        completion_date = rand(10..100).days.from_now.to_date
        completion_reason = ParticipantProfile::Mentor.mentor_completion_reasons.values.sample
        mentor.complete_training!(completion_date:, completion_reason:)
      end
    end

  private

    attr_reader :lead_provider, :cohort

    def initialize(name:, cohort:)
      @lead_provider = ::LeadProvider.find_by!(name:)
      @cohort = cohort
    end

    def create_mentor(school:, sparsity_uplift:, pupil_premium_uplift:)
      status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])

      mentor = create_participant(school_cohort: school_cohort(school:), profile_type: :mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
      rand(0..3).times do
        create_participant(school_cohort: school_cohort(school:), profile_type: :ect, mentor_profile: mentor, status:, sparsity_uplift:, pupil_premium_uplift:)
      end

      mentor
    end

    def create_participant(school_cohort:, profile_type: :ect, mentor_profile: nil, status: "active", sparsity_uplift: false, pupil_premium_uplift: false)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name:))
      teacher_profile = TeacherProfile.create!(user:, trn: random_or_nil_trn)
      schedule = ecf_schedules.sample
      participant_identity = Identity::Create.call(user:, origin: :ecf)

      lead_provider = school_cohort.lead_provider
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

        Induction::Enrol.call(participant_profile: profile, induction_programme:)

        return profile unless profile.active_record?

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

        return profile if profile.schedule.milestones.second.start_date > Date.current

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

        return profile if (profile.schedule.milestones.second.start_date + 1.day) > Time.zone.now

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

        Induction::Enrol.call(participant_profile: profile, induction_programme:)

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

        return profile if profile.schedule.milestones.second.start_date > Date.current

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

        return profile if (profile.schedule.milestones.second.start_date + 1.day) > Time.zone.now

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
      end
      school_cohort = school_cohort(school:)
      partnership = attach_partnership_to_school(school:)
      InductionProgramme.find_or_create_by!(
        partnership:,
        training_programme: "full_induction_programme",
        school_cohort:,
      )
      school
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
end
