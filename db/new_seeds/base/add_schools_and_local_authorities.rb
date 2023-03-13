# frozen_string_literal: true

require Rails.root.join("db/new_seeds/util/seed_utils")

@cohorts = Cohort.all
@lead_providers = LeadProvider.all

def add_school_to_local_authority(school:, local_authority:, nomination_email: false)
  FactoryBot.create(:seed_school_local_authority, school:, local_authority:)
  FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
    FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school:)

    @cohorts.sample(@cohorts.length).each do |cohort|
      FactoryBot.create(:seed_school_cohort, school:, cohort:)
    end

    @lead_providers.sample.tap do |lead_provider|
      scenarios = Random.rand(1..4).times.map do
        NewSeeds::Scenarios::Participants::Mentors::MentoringMultipleEctsWithSameProvider
          .new(school:, lead_provider:)
          .build(with_eligibility: false)
      end

      scenarios.flat_map(&:mentees).each do |participant_profile|
        Rails.logger.debug("seeding eligibility for #{participant_profile.user.full_name}")

        FactoryBot.create(:seed_ecf_participant_eligibility, random_weighted_eligibility_trait, participant_profile:)
      end
    end

    FactoryBot.create(:seed_nomination_email, :valid, sent_to: school.primary_contact_email) if nomination_email
  end
end

# create some local authorities
local_authorities = FactoryBot.create_list(:seed_local_authority, seed_quantity(:local_authorities))

# add some random schools to each LA
local_authorities.each do |local_authority|
  add_school_to_local_authority(school: FactoryBot.create(:seed_school), local_authority:)
end

# and add some with the old 'test' school format so they're easily findable in dev
1.upto(8) do |i|
  add_school_to_local_authority(
    school: FactoryBot.create(
      :seed_school,
      :with_induction_coordinator,
      urn: i.to_s.rjust(6, "0"),
      name: "ZZ Test School #{i}",
      primary_contact_email: "cpd-test+school-#{i}@digital.education.gov.uk",
    ),
    local_authority: local_authorities.sample,

    # this reimplements a feature of the legacy seeds
    # where 'ZZ Test School 3' has a NominationEmail record
    nomination_email: i == 3,
  )
end

# added some edge cases
Random.rand(1..4).times.map do
  add_school_to_local_authority(
    school: FactoryBot.create(
      :seed_school,
      :with_induction_coordinator,
      :cip_only,
    ),
    local_authority: local_authorities.sample,
  )
  add_school_to_local_authority(
    school: FactoryBot.create(
      :seed_school,
      :with_induction_coordinator,
      :ineligible,
    ),
    local_authority: local_authorities.sample,
  )
end

  # Extra school for UR purposes.
ur_school = FactoryBot.create(:seed_school,
                             :with_induction_coordinator,
                             urn: 801212,
                             name: "UR School",
                             primary_contact_email: "ur_school@digital.education.gov.uk")
ur_local_authority = local_authorities.sample
ur_cohorts = cohorts
ur_cohort_2021 = ur_cohorts.detect { |cohort| cohort.start_year == 2021 }
ur_cohort_2022 = ur_cohorts.detect { |cohort| cohort.start_year == 2022 }
ur_cohorts.each { |cohort| FactoryBot.create(:seed_school_cohort, school: ur_school, cohort:) }
ur_school_cohort_2021 = ur_school.school_cohorts.for_year(2021).first
ur_school_cohort_2022 = ur_school.school_cohorts.for_year(2022).first

ambition = LeadProvider.find_by(name: "Ambition Institute")
king_college_london = FactoryBot.create(:seed_delivery_partner, name: "King's College London")
FactoryBot.create(:seed_provider_relationship,
                  lead_provider: ambition,
                  delivery_partner: king_college_london,
                  cohort: ur_cohort_2021)

FactoryBot.create(:seed_provider_relationship,
                  lead_provider: ambition,
                  delivery_partner: king_college_london,
                  cohort: ur_cohort_2022)

ur_partnership_2021 = FactoryBot.create(:seed_partnership,
                                        cohort: ur_cohort_2021,
                                        school: ur_school,
                                        delivery_partner: king_college_london,
                                        lead_provider: ambition)

ur_partnership_2022 = FactoryBot.create(:seed_partnership,
                                        cohort: ur_cohort_2022,
                                        school: ur_school,
                                        delivery_partner: king_college_london,
                                        lead_provider: ambition)

ur_induction_programme_2021 = NewSeeds::Scenarios::InductionProgrammes::Fip
                                .new(school_cohort: ur_school_cohort_2021)
                                .build
                                .with_partnership(partnership: ur_partnership_2021)
                                .induction_programme

ur_induction_programme_2022 = NewSeeds::Scenarios::InductionProgrammes::Fip
                                .new(school_cohort: ur_school_cohort_2022)
                                .build
                                .with_partnership(partnership: ur_partnership_2022)
                                .induction_programme
fhtsh_ab = AppropriateBody.find_by(name: "Flying High Teaching School Hub")
nta_ab = AppropriateBody.find_by(name: "National Teacher Accreditation (NTA)")

FactoryBot.create(:seed_school_local_authority, school: ur_school, local_authority: ur_local_authority)
FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
  FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school: ur_school)

  mentor_jan = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2021, full_name: "Jan Tracee", email: "Jan.Tracee@school.com")
    .build
    .with_validation_data(full_name: "Jan Tracee", trn: "2342360", date_of_birth: Date.new(1960, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2021, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_marcy = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2021, full_name: "Marcy Erna", email: "Marcy.Erna@school.com")
    .build
    .with_validation_data(full_name: "Marcy Erna", trn: "2342370", date_of_birth: Date.new(1970, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2021, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_johannes = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2021, full_name: "Johannes Basir", email: "Johannes.Basir@school.com")
    .build
    .with_validation_data(full_name: "Johannes Basir", trn: "2342380", date_of_birth: Date.new(1980, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2021, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_hayate = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2021, full_name: "Hayate Jannat", email: "Hayate.Jannat@school.com")
    .build
    .with_validation_data(full_name: "Hayate Jannat", trn: "2342390", date_of_birth: Date.new(1990, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2021, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_nandita = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2021, full_name: "Nandita Carla", email: "Nandita.Carla@school.com")
    .build
    .with_validation_data(full_name: "Nandita Carla", trn: "2342395", date_of_birth: Date.new(1995, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2021, appropriate_body: fhtsh_ab)
    .participant_profile

  ect_susanna = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Susanna Peio",
                                                                 email: "Susanna.Peio@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Susanna Peio", trn: "1234567", date_of_birth: Date.new(2000, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_jan,
                              appropriate_body: fhtsh_ab)
  end

  ect_moreen = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Moreen Jacob",
                                                                 email: "Moreen.Jacob@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Moreen Jacob", trn: "8910111", date_of_birth: Date.new(1980, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_marcy,
                              appropriate_body: fhtsh_ab)
  end

  ect_walt = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
                                                                 full_name: "Walt Gunvald",
                                                                 email: "Walt.Gunvald@school.com")
                                                            .build(induction_start_date: Date.new(2021, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Walt Gunvald", trn: "2131415", date_of_birth: Date.new(1990, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_johannes,
                              appropriate_body: nta_ab)
  end

  ect_keshaun = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
                                                                 full_name: "Keshaun Edwyna",
                                                                 email: "Keshaun.Edwyna@school.com")
                                                            .build(induction_start_date: Date.new(2021, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Keshaun Edwyna", trn: "1617181", date_of_birth: Date.new(1995, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_hayate,
                              appropriate_body: nta_ab)
  end

  ect_lourenco = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Lourenco Firoozeh",
                                                                 email: "Lourenco.Firoozeh@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Lourenco Firoozeh", trn: "9202122", date_of_birth: Date.new(2002, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_jan,
                              appropriate_body: nta_ab)
  end

  ect_krsto = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Krsto Alexandra",
                                                                 email: "Krsto.Alexandra@school.com")
                                                            .build(induction_start_date: Date.new(2022, 4, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Krsto Alexandra", trn: "2324252", date_of_birth: Date.new(1985, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_marcy,
                              appropriate_body: nta_ab)
  end

  ect_ernestas = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
                                                                 full_name: "Ernestas Nuadha",
                                                                 email: "Ernestas.Nuadha@school.com")
                                                            .build(induction_start_date: Date.new(2022, 1, 1))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Ernestas Nuadha", trn: "6272829", date_of_birth: Date.new(2001, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_johannes,
                              appropriate_body: nta_ab)
  end

  ect_emanuele = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Emanuele Takumi",
                                                                 email: "Emanuele.Takumi@school.com")
                                                            .build(induction_start_date: Date.new(2023, 1, 1))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Emanuele Takumi", trn: "3031323", date_of_birth: Date.new(1998, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              training_status: "deferred",
                              mentor_profile: nil,
                              appropriate_body: fhtsh_ab)
  end
end
