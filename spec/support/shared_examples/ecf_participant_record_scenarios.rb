# frozen_string_literal: true

require "rails_helper"

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
  let(:appropriate_body_user) do
    NewSeeds::Scenarios::Users::AppropriateBodyUser
      .new(appropriate_body:)
      .build
      .user
  end

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
  let(:lead_provider_token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: lead_provider_details.cpd_lead_provider) }

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
  let(:delivery_partner_user) do
    NewSeeds::Scenarios::Users::DeliveryPartnerUser
      .new(delivery_partner:)
      .build
      .user
  end

  it "can see the participant listed in the delivery partner participants dashboard" do
    sign_in delivery_partner_user

    get "/delivery-partners/#{delivery_partner.id}/participants"

    expect(response.body).to include(CGI.escapeHTML(participant_profile.user.full_name))
    expect(response.body).to include(CGI.escapeHTML(preferred_identity.email))
  end
end
