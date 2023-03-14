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
fhtsh_ab = AppropriateBody.find_by(name: "Flying High Teaching School Hub")
nta_ab = AppropriateBody.find_by(name: "National Teacher Accreditation (NTA)")

ur_cohorts = cohorts
ur_cohort_2021 = ur_cohorts.detect { |cohort| cohort.start_year == 2021 }
ur_cohort_2022 = ur_cohorts.detect { |cohort| cohort.start_year == 2022 }

ur_school_cohort_2021 = FactoryBot.create(:seed_school_cohort, school: ur_school, cohort: ur_cohort_2021, appropriate_body: nta_ab)
ur_school_cohort_2022 = FactoryBot.create(:seed_school_cohort, school: ur_school, cohort: ur_cohort_2022, appropriate_body: fhtsh_ab)

ambition = LeadProvider.find_by(name: "Ambition Institute")
ucl = LeadProvider.find_by(name: "UCL Institute of Education")

wiltshire_schools_alliance = FactoryBot.create(:seed_delivery_partner, name: "Wiltshire schools alliance")
glf_wiltshire_teaching_school_hub = FactoryBot.create(:seed_delivery_partner, name: "GLF Wiltshire Teaching School Hub")

FactoryBot.create(:seed_provider_relationship,
                  lead_provider: ucl,
                  delivery_partner: wiltshire_schools_alliance,
                  cohort: ur_cohort_2021)

FactoryBot.create(:seed_provider_relationship,
                  lead_provider: ambition,
                  delivery_partner: glf_wiltshire_teaching_school_hub,
                  cohort: ur_cohort_2022)

ur_partnership_2021 = FactoryBot.create(:seed_partnership,
                                        cohort: ur_cohort_2021,
                                        school: ur_school,
                                        delivery_partner: wiltshire_schools_alliance,
                                        lead_provider: ucl)

ur_partnership_2022 = FactoryBot.create(:seed_partnership,
                                        cohort: ur_cohort_2022,
                                        school: ur_school,
                                        delivery_partner: glf_wiltshire_teaching_school_hub,
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

FactoryBot.create(:seed_school_local_authority, school: ur_school, local_authority: ur_local_authority)
FactoryBot.create(:seed_induction_coordinator_profile, :with_user).tap do |induction_coordinator_profile|
  FactoryBot.create(:seed_induction_coordinator_profiles_school, induction_coordinator_profile:, school: ur_school)

  mentor_jan = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2022, full_name: "Jan Tracey", email: "Jan.Tracee@school.com")
    .build
    .with_validation_data(full_name: "Jan Tracey", trn: "7654321", date_of_birth: Date.new(1960, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2022, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_marcy = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2022, full_name: "Marcy Erna", email: "Marcy.Erna@school.com")
    .build
    .with_validation_data(full_name: "Marcy Erna", trn: "5471234", date_of_birth: Date.new(1970, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2022, appropriate_body: fhtsh_ab)
    .participant_profile

  # mentor_johanne = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
  #   .new(school_cohort: ur_school_cohort_2022, full_name: "Johanne Bashir", email: "Johanne.Bashir@school.com")
  #   .build
  #   .with_validation_data(full_name: "Johanne Bashir", trn: "1357911", date_of_birth: Date.new(1980, 2, 1))
  #   .with_eligibility
  #   .with_induction_record(induction_programme: ur_induction_programme_2022, appropriate_body: fhtsh_ab)
  #   .participant_profile

  mentor_hayate = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2022, full_name: "Hayate Jannat", email: "Hayate.Jannat@school.com")
    .build
    .with_validation_data(full_name: "Hayate Jannat", trn: "2468101", date_of_birth: Date.new(1990, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2022, appropriate_body: fhtsh_ab)
    .participant_profile

  mentor_nandita = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(school_cohort: ur_school_cohort_2022, full_name: "Nandita Carla", email: "Nandita.Carla@school.com")
    .build
    .with_validation_data(full_name: "Nandita Carla", trn: "3456789", date_of_birth: Date.new(1995, 2, 1))
    .with_eligibility
    .with_induction_record(induction_programme: ur_induction_programme_2022, appropriate_body: fhtsh_ab)
    .participant_profile

  ect_susanna = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Susanna Pelo",
                                                                 email: "Susanna.Pelo@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility(qts: false, reason: "no_qts", status: "manual_check")
    ect.with_validation_data(full_name: "Susanna Pelo", trn: "1234567", date_of_birth: Date.new(2000, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_jan,
                              appropriate_body: fhtsh_ab)
  end

  ect_memet = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Memet Jacob",
                                                                 email: "Memet.Jacob@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Memet Jacob", trn: "8910111", date_of_birth: Date.new(1980, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              mentor_profile: mentor_marcy,
                              appropriate_body: fhtsh_ab)
  end

  # ect_walt = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
  #                                                                full_name: "Walt Gunson",
  #                                                                email: "Walt.Gunson@school.com")
  #                                                           .build(induction_start_date: Date.new(2021, 9, 5))
  #                                                           .tap do |ect|
  #   ect.with_eligibility
  #   ect.with_validation_data(full_name: "Walt Gunson", trn: "2131415", date_of_birth: Date.new(1990, 2, 1))
  #   ect.with_induction_record(induction_programme: ur_induction_programme_2021,
  #                             mentor_profile: mentor_jan,
  #                             appropriate_body: nta_ab)
  # end

  ect_keisha = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
                                                                 full_name: "Keisha Edwina",
                                                                 email: "Keisha.Edwina@school.com")
                                                            .build(induction_start_date: Date.new(2021, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Keisha Edwina", trn: "1617181", date_of_birth: Date.new(1995, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_hayate,
                              appropriate_body: nta_ab)
  end

  ect_laurence = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Laurence Firoozeh",
                                                                 email: "Laurence.Firoozeh@school.com")
                                                            .build(induction_start_date: Date.new(2022, 9, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Laurence Firoozeh", trn: "9202122", date_of_birth: Date.new(2002, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_jan,
                              appropriate_body: nta_ab)
  end

  ect_kirsty = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                 full_name: "Kirsty Alexandra",
                                                                 email: "Kirsty.Alexandra@school.com")
                                                            .build(induction_start_date: Date.new(2022, 4, 5))
                                                            .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Kirsty Alexandra", trn: "2324252", date_of_birth: Date.new(1985, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2021,
                              mentor_profile: mentor_marcy,
                              appropriate_body: nta_ab)
  end

  # ect_ernie = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2021,
  #                                                                full_name: "Ernie Nuadha",
  #                                                                email: "Ernie.Nuadha@school.com")
  #                                                           .build(induction_start_date: Date.new(2022, 1, 1))
  #                                                           .tap do |ect|
  #   ect.with_eligibility
  #   ect.with_validation_data(full_name: "Ernie Nuadha", trn: "6272829", date_of_birth: Date.new(2001, 2, 1))
  #   ect.with_induction_record(induction_programme: ur_induction_programme_2021,
  #                             mentor_profile: mentor_johanne,
  #                             appropriate_body: nta_ab)
  # end

  ect_emmanuel = NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: ur_school_cohort_2022,
                                                                   full_name: "Emmanuel Takumi",
                                                                   email: "Emmanuel.Takumi@school.com")
                                                              .build(induction_start_date: Date.new(2023, 1, 1))
                                                              .tap do |ect|
    ect.with_eligibility
    ect.with_validation_data(full_name: "Emmanuel Takumi", trn: "3031323", date_of_birth: Date.new(1998, 2, 1))
    ect.with_induction_record(induction_programme: ur_induction_programme_2022,
                              training_status: "deferred",
                              mentor_profile: mentor_hayate,
                              appropriate_body: fhtsh_ab)
  end
end
