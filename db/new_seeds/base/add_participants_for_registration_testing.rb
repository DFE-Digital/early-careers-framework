# frozen_string_literal: true

school = FactoryBot.create(:seed_school, :with_induction_coordinator)
local_authority = LocalAuthority.order("RANDOM()").first
appropriate_body = AppropriateBody.order("RANDOM()").first
delivery_partner = DeliveryPartner.order("RANDOM()").first

lead_providers = LeadProvider.where(name: ["Ambition Institute", "Best Practice Network", "Capita", "Education Development Trust"])

FactoryBot.create(:seed_school_local_authority, school:, local_authority:)

Cohort.where(start_year: 2.years.ago.year..).find_each do |cohort|
  school_cohort = FactoryBot.create(:seed_school_cohort, :fip, school:, cohort:, appropriate_body:)

  lead_providers.each do |lead_provider|
    FactoryBot.create(
      :seed_provider_relationship,
      lead_provider:,
      delivery_partner:,
      cohort:,
    )

    partnership = FactoryBot.create(
      :seed_partnership,
      cohort:,
      school:,
      delivery_partner:,
      lead_provider:,
    )

    induction_programme = NewSeeds::Scenarios::InductionProgrammes::Fip
      .new(school_cohort:)
      .build
      .with_partnership(partnership:)
      .induction_programme

    FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
      FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school:)

      mentor_profile = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme:, appropriate_body:)
        .participant_profile

      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme:, appropriate_body:)
        .participant_profile

      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_eligibility
        .with_validation_data
        .with_induction_record(induction_programme:, appropriate_body:, mentor_profile:)

      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_eligibility
        .with_validation_data
        .with_induction_record(induction_programme:, appropriate_body:)
    end
  end
end
