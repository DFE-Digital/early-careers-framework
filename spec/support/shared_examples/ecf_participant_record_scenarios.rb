# frozen_string_literal: true

require "rails_helper"

RSpec.shared_context "a system that has the current academic year configured" do |start_year|
  let(:cohort_details) do
    NewSeeds::Scenarios::Cohorts::Cohort.new(start_year:)
                                        .build
                                        .with_schedule_and_milestone
  end
  let(:cohort) do
    cohort = cohort_details.cohort
    allow(Cohort).to receive(:current).and_return(cohort)
    cohort
  end

  let(:privacy_policy) do
    privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid)
    PrivacyPolicy::Publish.call
    privacy_policy
  end
end

RSpec.shared_context "an appropriate body" do |name|
  let(:appropriate_body) { FactoryBot.create :seed_appropriate_body, :teaching_school_hub, name: }
  let(:appropriate_body_user_details) { NewSeeds::Scenarios::Users::AppropriateBodyUser.new(appropriate_body:).build }
  let(:appropriate_body_user) { appropriate_body_user_details.user }
end

RSpec.shared_context "a lead provider and their delivery partner" do |lead_provider_name, delivery_partner_name|
  let(:lead_provider_details) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider.new(name: lead_provider_name, cohorts: [cohort])
                                                    .build
                                                    .with_delivery_partner(name: delivery_partner_name)
  end
  let(:lead_provider) { lead_provider_details.lead_provider }
  let(:lead_provider_token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: lead_provider_details.cpd_lead_provider) }

  let(:delivery_partner) { lead_provider_details.delivery_partner }
  let(:delivery_partner_user_details) { NewSeeds::Scenarios::Users::DeliveryPartnerUser.new(delivery_partner:).build }
  let(:delivery_partner_user) { delivery_partner_user_details.user }
end

RSpec.shared_context "a school that has chosen FIP as their default induction programme" do |school_name|
  let(:school_details) do
    NewSeeds::Scenarios::Schools::School.new(name: school_name)
                                        .build
                                        .with_an_induction_tutor(accepted_privacy_policy: privacy_policy)
  end
  let(:school) { school_details.school }

  let(:school_cohort_details) do
    NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort:, school:)
                                           .build
                                           .with_partnership(lead_provider:, delivery_partner:)
                                           .with_programme(default_induction_programme: true)
  end
  let(:school_cohort) { school_cohort_details.school_cohort }
end

RSpec.shared_context "a school that has chosen CIP as their default induction programme" do |school_name|
  let(:school_details) do
    NewSeeds::Scenarios::Schools::School.new(name: school_name)
                                        .build
                                        .with_an_induction_tutor(accepted_privacy_policy: privacy_policy)
  end
  let(:school) { school_details.school }

  let(:school_cohort_details) do
    core_induction_programme = FactoryBot.create :seed_core_induction_programme, name: "Education Development Trust"

    NewSeeds::Scenarios::SchoolCohorts::Cip.new(cohort:, school:)
                                           .build
                                           .with_programme(core_induction_programme:, default_induction_programme: true)
  end
  let(:school_cohort) { school_cohort_details.school_cohort }
end

RSpec.shared_context "an ECF participant" do |scenario|
  let!(:participant_details) { scenario.new(school_cohort:).build(appropriate_body:) }
  let(:teacher_profile) { participant_details.teacher_profile }
  let(:participant_profile) { participant_details.participant_profile }
  let(:preferred_identity) { participant_details.participant_identity }
end

RSpec.shared_examples "As their current school induction tutor" do
  it "can see the participant listed in the school participants dashboard" do
    sign_in school_details.induction_tutor

    get "/schools/#{school.slug}/participants"

    # expect(subject).to include_participant_in_school_participants_dashboard(participant_profile:)
    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
  end

  it "can see the participants details in the school participant record page" do
    sign_in school_details.induction_tutor

    get "/schools/#{school.slug}/participants/#{participant_profile.id}"

    # expect(subject).to include_participant_in_school_participants_dashboard(participant_profile:, preferred_identity:)
    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
    expect(response.body).to include(CGI.escapeHTML(preferred_identity.email))
  end
end

RSpec.shared_examples "As their current appropriate body" do
  it "can see the participant listed in the appropriate body participants dashboard" do
    sign_in appropriate_body_user

    get "/appropriate-bodies/#{appropriate_body.id}/participants"

    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
    expect(response.body).to include(CGI.escapeHTML(preferred_identity.email))
  end
end

RSpec.shared_examples "As the support for ECTs service" do |programme_type:, materials: "none"|
  let(:app_service_token) { EngageAndLearnApiToken.create_with_random_token! }

  let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
  let(:api_record) { parsed_response[:data][0] }

  it "can see the participant listed in the ECF participants API v1 endpoint" do
    default_headers[:Authorization] = "Bearer #{app_service_token}"

    get "/api/v1/ecf-users"

    expected = {
      id: participant_profile.user.id,
      type: "user",
      attributes: {
        email: participant_profile.user.email,
        full_name: participant_profile.user.full_name,
        cohort: cohort.start_year,
        core_induction_programme: materials,
        induction_programme_choice: programme_type,
        registration_completed: true,
        user_type: "early_career_teacher",
      },
    }

    # expect(subject).to be_an_ect_user_api_record(cohort:, participant_profile:)
    expect(api_record).to eql expected
  end
end

RSpec.shared_examples "As their current lead provider" do
  let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }
  let(:api_record) { parsed_response[:data][0] }

  it "can see the participant listed in the ECF participants API v1 endpoint" do
    default_headers[:Authorization] = "Bearer #{lead_provider_token}"

    get "/api/v1/participants/ecf"

    expected = {
      id: participant_profile.user.id,
      type: "participant",
      attributes: {
        email: participant_profile.user.email,
        full_name: participant_profile.user.full_name,
        mentor_id: nil,
        school_urn: school.urn,
        participant_type: "ect",
        cohort: cohort.start_year.to_s,
        teacher_reference_number: teacher_profile.trn,
        teacher_reference_number_validated: true,
        eligible_for_funding: true,
        pupil_premium_uplift: true,
        sparsity_uplift: true,
        status: "active",
        training_status: "active",
        training_record_id: participant_profile.id,
        schedule_identifier: "ecf-standard-september",
        updated_at: participant_profile.user.updated_at.iso8601,
      },
    }

    # expect(subject).to be_an_ecf_participant_api_record(cohort:, participant_profile:, teacher_profile)
    expect(api_record).to eql expected
  end

  it "can see the participant listed in the Participants API v1 endpoint" do
    default_headers[:Authorization] = "Bearer #{lead_provider_token}"

    get "/api/v1/participants"

    expected = {
      id: participant_profile.user.id,
      type: "participant",
      attributes: {
        email: participant_profile.user.email,
        full_name: participant_profile.user.full_name,
        mentor_id: nil,
        school_urn: school.urn,
        participant_type: "ect",
        cohort: cohort.start_year.to_s,
        teacher_reference_number: teacher_profile.trn,
        teacher_reference_number_validated: true,
        eligible_for_funding: true,
        pupil_premium_uplift: true,
        sparsity_uplift: true,
        status: "active",
        training_status: "active",
        training_record_id: participant_profile.id,
        schedule_identifier: "ecf-standard-september",
        updated_at: participant_profile.user.updated_at.iso8601,
      },
    }

    # expect(subject).to be_an_participant_api_record(cohort:, participant_profile:, teacher_profile)
    expect(api_record).to eql expected
  end
end

RSpec.shared_examples "As their current delivery provider" do
  it "can see the participant listed in the delivery partner participants dashboard" do
    sign_in delivery_partner_user

    get "/delivery-partners/#{delivery_partner.id}/participants"

    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
    expect(response.body).to include(CGI.escapeHTML(preferred_identity.email))
  end
end
