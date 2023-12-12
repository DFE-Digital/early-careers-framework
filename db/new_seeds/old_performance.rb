# frozen_string_literal: true

email_domain = "@example.com" # Prevent low effort email scraping

num_authorities = ENV.fetch("PERF_NUM_AUTHORITIES", 10).to_i
num_schools = ENV.fetch("PERF_NUM_SCHOOLS", 10).to_i
num_participants = ENV.fetch("PERF_NUM_PARTICIPANTS", 10).to_i
lead_provider_api_token = ENV.fetch("PERF_LEAD_PROVIDER_API_TOKEN", "performance-api-token")

Faker::Config.locale = "en-GB"

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

Rails.logger.info "Seeding database"

NewSeeds::Scenarios::Cohorts::Cohort.new(start_year: 2020).build

# create ECF cohorts since 2020 with default schedule and milestone
end_year = Date.current.month < 9 ? Date.current.year : Date.current.year + 1
(2021..end_year).each do |start_year|
  NewSeeds::Scenarios::Cohorts::Cohort.new(start_year:).build.with_schedule_and_milestone
end

Rails.logger.info "Created ECF cohorts, schedules and milestones"

privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid).tap { |_pp| PrivacyPolicy::Publish.call }

Rails.logger.info "Created school admin privacy policy"

# Create an ECF training provider network
lead_provider_name = "Lead Provider: Performance Testing"
delivery_partner_name = "Delivery Partner: Performance Testing"
ecf_lead_provider = NewSeeds::Scenarios::LeadProviders::LeadProvider
                      .new(cohorts: [Cohort.current, Cohort.previous], name: lead_provider_name)
                      .build
                      .with_delivery_partner(name: delivery_partner_name)
                      .tap { |lead_provider| NewSeeds::Scenarios::Users::DeliveryPartnerUser.new(full_name: delivery_partner_name, delivery_partner: lead_provider.delivery_partner).build }

LeadProviderApiToken.create_with_known_token! lead_provider_api_token, cpd_lead_provider: ecf_lead_provider.cpd_lead_provider

Rails.logger.info "Created ECF training provider network"

performance_contract_data = {
  "version": "1.0.0",
  "uplift_target": 0.33,
  "uplift_amount": 100,
  "recruitment_target": 2000,
  "set_up_fee": 149_861,
  "band_a": {
    "max": 2000,
    "per_participant": 995,
  },
  "band_b": {
    "min": 2001,
    "max": 4000,
    "per_participant": 979,
  },
  "band_c": {
    "min": 4001,
    "per_participant": 966,
  },
}

contract_args = {
  lead_provider: ecf_lead_provider.lead_provider,
  version: performance_contract_data[:version],
  uplift_target: performance_contract_data[:uplift_target],
  uplift_amount: performance_contract_data[:uplift_amount],
  recruitment_target: performance_contract_data[:recruitment_target],
  set_up_fee: performance_contract_data[:set_up_fee],
  raw: performance_contract_data.to_json,
}

previous_call_off_contract = CallOffContract.create!(cohort: Cohort.previous, **contract_args)
current_call_off_contract = CallOffContract.create!(cohort: Cohort.current, **contract_args)

%i[band_a band_b band_c].each do |band|
  src = performance_contract_data[band]

  ParticipantBand.create!(
    call_off_contract: previous_call_off_contract,
    min: src[:min],
    max: src[:max],
    per_participant: src[:per_participant],
  )

  ParticipantBand.create!(
    call_off_contract: current_call_off_contract,
    min: src[:min],
    max: src[:max],
    per_participant: src[:per_participant],
  )
end

Rails.logger.info "Created ECF Call of contract"

la_index = 0
school_index = 0
participant_index = 0
num_authorities.times do
  la_index += 1

  la_num = la_index.to_s.rjust(3, "0")
  local_authority = LocalAuthority.create!(
    name: "ZZ Performance Local Authority: #{la_num}",
    code: "ZZ_PERF_LA_#{la_index}",
  )

  Rails.logger.info "Created '#{local_authority.name}'"

  num_schools.times do
    school_index += 1

    urn = "9#{school_index.to_s.rjust(5, '0')}"
    school_name = "ZZ Performance School: #{urn}"
    sit_email_address = "cpd-performance-tutor-#{urn}#{email_domain}"

    school = NewSeeds::Scenarios::Schools::School
               .new(name: school_name, urn:)
               .build
               .with_an_induction_tutor(full_name: school_name, email: sit_email_address, accepted_privacy_policy: privacy_policy)
               .tap { |builder| SchoolLocalAuthority.create! school: builder.school, local_authority:, start_year: 2019 }
               .school

    current_school_cohort = NewSeeds::Scenarios::SchoolCohorts::Fip
                              .new(cohort: Cohort.current, school:)
                              .build
                              .with_partnership(lead_provider: ecf_lead_provider.lead_provider, delivery_partner: ecf_lead_provider.delivery_partner)
                              .with_programme(default_induction_programme: true)

    previous_school_cohort = NewSeeds::Scenarios::SchoolCohorts::Fip
                               .new(cohort: Cohort.previous, school:)
                               .build
                               .with_partnership(lead_provider: ecf_lead_provider.lead_provider, delivery_partner: ecf_lead_provider.delivery_partner)
                               .with_programme(default_induction_programme: true)

    Rails.logger.info "Created '#{school_name}' with urn ##{urn}"

    num_participants.times do
      participant_index += 1

      participant_num = participant_index.to_s.rjust(6, "0")
      participant_name = "ZZ Performance ECT: #{participant_num}"
      participant_email_address = "cpd-performance-ect-#{participant_num}#{email_domain}"

      school_cohort = if participant_index.even?
                        current_school_cohort.school_cohort
                      else
                        previous_school_cohort.school_cohort
                      end

      NewSeeds::Scenarios::Participants::Ects::EctInTraining
        .new(school_cohort:, full_name: participant_name, email: participant_email_address)
        .build
    end
  end
end
