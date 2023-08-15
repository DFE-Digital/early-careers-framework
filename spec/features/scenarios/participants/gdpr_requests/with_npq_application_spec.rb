# frozen_string_literal: true

require "rails_helper"

RSpec.feature "GDPR Request: with NPQ Application", type: :feature do
  let!(:participant_details) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNPQApplicationAfterGDPRRequest
      .new(school_cohort:, full_name: participant_full_name)
      .build
  end
  let(:participant_id) { participant_profile.user.id }
  let(:participant_email) { participant_profile.user.email }
  let(:participant_full_name) { "Mentor: with NPQ Application" }
  let(:teacher_reference_number) { teacher_profile.trn }
  let(:training_record_id) { participant_profile.id }
  let(:school_name) { "School chosen FIP in 2023" }
  let(:sit_full_name) { "#{school_name} SIT" }
  let(:lead_provider_name) { "Lead Provider for FIP in 2023" }
  let(:delivery_partner_name) { "Delivery Partner for FIP in 2023" }
  let(:appropriate_body_name) { "#{school_name} Appropriate Body" }
  let(:start_year) { 2023 }
  let(:npq_application_id) { participant_details.npq_application.id }

  let(:cohort) do
    Cohort.find_by(start_year:)
          .tap { |current_cohort| allow(Cohort).to receive(:current).and_return(current_cohort) }
  end

  let(:privacy_policy) do
    FactoryBot.create(:seed_privacy_policy, :valid).tap { |_pp| PrivacyPolicy::Publish.call }
  end

  let(:appropriate_body) do
    FactoryBot.create(:seed_appropriate_body, :teaching_school_hub, name: appropriate_body_name)
              .tap { |appropriate_body| NewSeeds::Scenarios::Users::AppropriateBodyUser.new(full_name: appropriate_body_name, appropriate_body:).build }
  end

  let(:lead_provider_details) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider
      .new(cohorts: [cohort], name: lead_provider_name)
      .build
      .with_delivery_partner(name: delivery_partner_name)
      .tap { |lead_provider| NewSeeds::Scenarios::Users::DeliveryPartnerUser.new(full_name: delivery_partner_name, delivery_partner: lead_provider.delivery_partner).build }
  end
  let(:lead_provider) { lead_provider_details.lead_provider }
  let(:delivery_partner) { lead_provider_details.delivery_partner }

  let(:npq_lead_provider) { participant_details.npq_application.npq_lead_provider }

  let(:school_details) do
    NewSeeds::Scenarios::Schools::School
      .new(name: school_name)
      .build
      .with_an_induction_tutor(full_name: sit_full_name, accepted_privacy_policy: privacy_policy)
  end
  let(:school) { school_details.school }

  let(:school_cohort_details) do
    NewSeeds::Scenarios::SchoolCohorts::Fip
      .new(cohort:, school:)
      .build
      .with_partnership(lead_provider:, delivery_partner:)
      .with_programme(default_induction_programme: true)
  end
  let(:school_cohort) { school_cohort_details.school_cohort }

  let(:teacher_profile) { participant_details.teacher_profile }
  let(:participant_profile) { participant_details.participant_profile }
  let(:preferred_identity) { participant_details.participant_identity }

  scenario "The current school induction tutor can locate a record for the Mentor" do
    given_i_sign_in_as_the_user_with_the_full_name sit_full_name

    school_dashboard = Pages::SchoolDashboardPage.load(slug: school.slug)
    school_dashboard.view_participant_dashboard

    participant_dashboard = Pages::SchoolParticipantsDashboardPage.loaded(slug: school.slug)

    participant_details = participant_dashboard.view_participant participant_full_name
    expect(participant_details).to have_participant_name participant_full_name
    expect(participant_details).to have_email participant_email
    expect(participant_details).to have_full_name participant_full_name
  end

  scenario "The current appropriate body can locate a record for the Mentor", :skip do
    given_i_sign_in_as_the_user_with_the_full_name appropriate_body_name

    appropriate_body_portal = Pages::AppropriateBodyPortal.loaded

    appropriate_body_portal.get_participant(participant_full_name)
    expect(appropriate_body_portal).to have_full_name participant_full_name
    expect(appropriate_body_portal).to have_email_address participant_email
    expect(appropriate_body_portal).to have_teacher_reference_number teacher_reference_number
  end

  scenario "The current lead provider can locate a record for the Mentor" do
    lead_provider_token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: lead_provider_details.cpd_lead_provider)

    ecf_participant_endpoint = APIs::ECFParticipantsEndpoint.load(lead_provider_token)

    ecf_participant_endpoint.get_participant participant_id
    expect(ecf_participant_endpoint).to have_email_address participant_email
    expect(ecf_participant_endpoint).to have_full_name participant_full_name
    expect(ecf_participant_endpoint).to have_trn teacher_reference_number

    participant_endpoint = APIs::ParticipantsEndpoint.load(lead_provider_token)

    participant_endpoint.get_participant participant_id
    expect(participant_endpoint).to have_email_address participant_email
    expect(participant_endpoint).to have_full_name participant_full_name
    expect(participant_endpoint).to have_trn teacher_reference_number
  end

  scenario "The current lead provider can locate a record for the NPQ Application" do
    lead_provider_token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: npq_lead_provider.cpd_lead_provider)

    npq_application_endpoint = APIs::NPQApplicationsEndpoint.load(lead_provider_token)

    npq_application_endpoint.get_application npq_application_id
    expect(npq_application_endpoint).to have_email_address participant_email
    expect(npq_application_endpoint).to have_full_name participant_full_name
    expect(npq_application_endpoint).to have_trn teacher_reference_number
  end

  scenario "The current delivery partner can locate a record for the Mentor" do
    given_i_sign_in_as_the_user_with_the_full_name delivery_partner_name

    delivery_partner_portal = Pages::DeliveryPartnerPortal.loaded

    delivery_partner_portal.get_participant participant_full_name
    expect(delivery_partner_portal).to have_full_name participant_full_name
    expect(delivery_partner_portal).to have_email_address participant_email
    expect(delivery_partner_portal).to have_teacher_reference_number teacher_reference_number
  end

  scenario "The Support for ECTs service can locate a record for the Mentor" do
    user_endpoint = APIs::ECFUsersEndpoint.load

    user_endpoint.get_user participant_id
    expect(user_endpoint).to have_email participant_email
    expect(user_endpoint).to have_full_name participant_full_name
  end

  scenario "A DfE admin user can locate the record for the Mentor" do
    given_i_sign_in_as_an_admin_user

    participant_list = Pages::AdminSupportParticipantList.load

    participant_detail = participant_list.view_participant participant_full_name
    expect(participant_detail).to have_full_name participant_full_name
    expect(participant_detail).to have_email_address participant_email
    expect(participant_detail).to have_trn teacher_reference_number
  end

  scenario "A DfE admin user can locate the record for the NPQ Application" do
    given_i_sign_in_as_an_admin_user

    npq_application_list = Pages::AdminSupportNPQApplicationList.load

    npq_application_list.get_application participant_email
    expect(npq_application_list).to have_email_address participant_email

    npq_application_detail = npq_application_list.view_application participant_email
    expect(npq_application_detail).to have_preferred_name participant_full_name
    expect(npq_application_detail).to have_email_address participant_email
    expect(npq_application_detail).to have_trn teacher_reference_number
  end

  scenario "A DfE finance user can locate the record for the Mentor" do
    given_i_sign_in_as_a_finance_user

    drilldown_search = Pages::FinanceParticipantDrilldownSearch.load

    drilldown = drilldown_search.find participant_id
    expect(drilldown).to have_full_name participant_full_name
  end

  scenario "A DfE finance user can locate the record for the NPQ Application", skip: "No additional details are shown" do
    given_i_sign_in_as_a_finance_user

    drilldown_search = Pages::FinanceParticipantDrilldownSearch.load

    drilldown = drilldown_search.find participant_id
    expect(drilldown).to have_full_name participant_full_name
  end
end
