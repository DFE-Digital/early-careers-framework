# frozen_string_literal: true

require "rails_helper"

RSpec.feature "ECT doing FIP: no validation", type: :feature do
  let!(:participant_details) do
    NewSeeds::Scenarios::Participants::Ects::EctInTraining
      .new(school_cohort:, full_name: participant_full_name)
      .build(appropriate_body:)
  end
  let(:participant_id) { participant_profile.user.id }
  let(:participant_email) { participant_profile.user.email }
  let(:teacher_reference_number) { teacher_profile.trn }
  let(:training_record_id) { participant_profile.id }
  let(:participant_full_name) { "ECT doing FIP: no validation" }
  let(:school_name) { "School chosen FIP in #{start_year}" }
  let(:sit_full_name) { "#{school_name} SIT" }
  let(:lead_provider_name) { "Lead Provider for FIP in #{start_year}" }
  let(:delivery_partner_name) { "Delivery Partner for FIP in #{start_year}" }
  let(:appropriate_body_name) { "#{school_name} Appropriate Body" }
  let(:participant_type) { "early_career_teacher" }
  let(:short_participant_type) { "ect" }
  let(:long_participant_type) { "Early career teacher" }
  let(:participant_class) { "ParticipantProfile::ECT" }
  let(:programme_type) { "full_induction_programme" }
  let(:programme_name) { "Full induction programme" }
  let(:schedule_identifier) { "ecf-standard-september" }
  let(:cip_materials) { "none" }
  let(:start_year) { Cohort.next.start_year }
  let(:registration_completed) { true }
  let(:participant_status) { "active" }
  let(:training_record_state) { "Eligible to start" }
  let(:school_record_state) { "Eligible for training" }
  let(:delivery_partner_record_state) { "Training or eligible for training" }
  let(:appropriate_body_record_state) { "Training or eligible for training" }

  let(:cohort) do
    Cohort.find_by(start_year:)
          .tap { |current_cohort| allow(Cohort).to receive(:current).and_return(current_cohort) }
  end

  let(:privacy_policy) do
    FactoryBot.create(:seed_privacy_policy, :valid).tap { |_pp| PrivacyPolicy::Publish.call }
  end

  let(:appropriate_body) do
    FactoryBot.create(:seed_appropriate_body, :teaching_school_hub, name: appropriate_body_name)
              .tap { |appropriate_body| NewSeeds::Scenarios::Users::AppropriateBodyUser.new(appropriate_body:).build }
  end
  let(:ab_full_name) { appropriate_body.appropriate_body_profiles.first.full_name }

  let(:lead_provider_details) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider
      .new(cohorts: [cohort], name: lead_provider_name)
      .build
      .with_delivery_partner(name: delivery_partner_name)
      .tap { |lead_provider| NewSeeds::Scenarios::Users::DeliveryPartnerUser.new(full_name: delivery_partner_name, delivery_partner: lead_provider.delivery_partner).build }
  end
  let(:lead_provider) { lead_provider_details.lead_provider }
  let(:delivery_partner) { lead_provider_details.delivery_partner }

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

  scenario "The current school induction tutor can locate a record for the ECT" do
    inside_registration_window(cohort:) do
      given_i_sign_in_as_the_user_with_the_full_name sit_full_name

      school_dashboard = Pages::SchoolDashboardPage.load(slug: school.slug)
      school_dashboard.view_participant_dashboard

      participant_dashboard = Pages::SchoolParticipantsDashboardPage.loaded(slug: school.slug)
      participant_dashboard.view_participant participant_full_name

      participant_details = Pages::SchoolParticipantDetailsPage.loaded(slug: school.slug, participant_id: training_record_id)
      expect(participant_details).to have_participant_name participant_full_name
      expect(participant_details).to have_email participant_email
      expect(participant_details).to have_full_name participant_full_name
      expect(participant_details).to have_status school_record_state
    end
  end

  scenario "The current appropriate body can locate a record for the ECT", :skip do
    given_i_sign_in_as_the_user_with_the_full_name ab_full_name

    appropriate_body_portal = Pages::AppropriateBodyPortal.loaded
    appropriate_body_portal.get_participant(participant_full_name)

    expect(appropriate_body_portal).to have_full_name participant_full_name
    expect(appropriate_body_portal).to have_email_address participant_email
    expect(appropriate_body_portal).to have_teacher_reference_number teacher_reference_number
    expect(appropriate_body_portal).to have_participant_type long_participant_type
    expect(appropriate_body_portal).to have_lead_provider_name lead_provider_name
    expect(appropriate_body_portal).to have_school_name school_name
    expect(appropriate_body_portal).to have_school_urn school.urn
    expect(appropriate_body_portal).to have_academic_year start_year
    expect(appropriate_body_portal).to have_training_record_status appropriate_body_record_state
  end

  scenario "The current lead provider can locate a record for the ECT" do
    lead_provider_token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: lead_provider_details.cpd_lead_provider)

    ecf_participant_endpoint = APIs::ECFParticipantsEndpoint.load(lead_provider_token)
    ecf_participant_endpoint.get_participant participant_id

    expect(ecf_participant_endpoint).to have_email_address participant_email
    expect(ecf_participant_endpoint).to have_full_name participant_full_name
    expect(ecf_participant_endpoint).to have_mentor_id nil
    expect(ecf_participant_endpoint).to have_school_urn school.urn
    expect(ecf_participant_endpoint).to have_participant_type short_participant_type
    expect(ecf_participant_endpoint).to have_cohort start_year
    expect(ecf_participant_endpoint).to have_trn teacher_reference_number
    # teacher_reference_number_validated: true,
    expect(ecf_participant_endpoint).to be_eligible_for_funding
    expect(ecf_participant_endpoint).to have_pupil_premium_uplift
    expect(ecf_participant_endpoint).to have_sparsity_uplift
    expect(ecf_participant_endpoint).to have_status participant_status
    expect(ecf_participant_endpoint).to have_training_record_id training_record_id
    expect(ecf_participant_endpoint).to have_schedule_identifier schedule_identifier

    participant_endpoint = APIs::ParticipantsEndpoint.load(lead_provider_token)
    participant_endpoint.get_participant participant_id

    expect(participant_endpoint).to have_email_address participant_email
    expect(participant_endpoint).to have_full_name participant_full_name
    expect(participant_endpoint).to have_mentor_id nil
    expect(participant_endpoint).to have_school_urn school.urn
    expect(participant_endpoint).to have_participant_type short_participant_type
    expect(participant_endpoint).to have_cohort start_year
    expect(participant_endpoint).to have_trn teacher_reference_number
    # teacher_reference_number_validated: true,
    expect(participant_endpoint).to be_eligible_for_funding
    expect(participant_endpoint).to have_pupil_premium_uplift
    expect(participant_endpoint).to have_sparsity_uplift
    expect(participant_endpoint).to have_status participant_status
    expect(participant_endpoint).to have_training_record_id training_record_id
    expect(participant_endpoint).to have_schedule_identifier schedule_identifier
  end

  scenario "The current delivery partner can locate a record for the ECT" do
    given_i_sign_in_as_the_user_with_the_full_name delivery_partner_name

    delivery_partner_portal = Pages::DeliveryPartnerPortal.loaded
    delivery_partner_portal.get_participant(participant_full_name)

    expect(delivery_partner_portal).to have_full_name participant_full_name
    expect(delivery_partner_portal).to have_email_address participant_email
    expect(delivery_partner_portal).to have_teacher_reference_number teacher_reference_number
    expect(delivery_partner_portal).to have_participant_type long_participant_type
    expect(delivery_partner_portal).to have_lead_provider_name lead_provider_name
    expect(delivery_partner_portal).to have_school_name school_name
    expect(delivery_partner_portal).to have_school_urn school.urn
    expect(delivery_partner_portal).to have_academic_year start_year
    expect(delivery_partner_portal).to have_training_record_status delivery_partner_record_state
  end

  scenario "The Support for ECTs service can locate a record for the CIP ECT" do
    user_endpoint = APIs::ECFUsersEndpoint.load
    user_endpoint.get_user participant_id

    expect(user_endpoint).to have_email participant_email
    expect(user_endpoint).to have_full_name participant_full_name
    expect(user_endpoint).to have_cohort start_year
    expect(user_endpoint).to have_core_induction_programme cip_materials
    expect(user_endpoint).to have_induction_programme_choice programme_type
    expect(user_endpoint).to have_registration_completed registration_completed
    expect(user_endpoint).to have_user_type participant_type
  end

  scenario "A DfE admin user can locate the record for the ECT" do
    given_i_sign_in_as_an_admin_user

    participant_list = Pages::AdminSupportParticipantList.load
    participant_list.view_participant participant_full_name

    participant_detail = Pages::AdminSupportParticipantDetail.loaded(participant_id: training_record_id)
    expect(participant_detail).to have_full_name participant_full_name
    expect(participant_detail).to have_email_address participant_email
    expect(participant_detail).to have_trn teacher_reference_number
    expect(participant_detail).to have_cohort start_year
    expect(participant_detail).to have_user_id participant_id

    participant_detail.open_training_tab

    participant_training = Pages::AdminSupportParticipantTraining.loaded(participant_id: training_record_id)
    expect(participant_training).to have_cohort start_year
    expect(participant_training).to have_school_name school.name
    expect(participant_training).to have_lead_provider lead_provider_name
  end

  scenario "A DfE finance user can locate the record for the ECT" do
    given_i_sign_in_as_a_finance_user

    drilldown_search = Pages::FinanceParticipantDrilldownSearch.load
    drilldown_search.find participant_id

    drilldown = Pages::FinanceParticipantDrilldown.loaded(user_id: participant_id)
    expect(drilldown).to have_participant_id participant_id
    expect(drilldown).to have_full_name participant_full_name
    expect(drilldown).to have_lead_provider lead_provider_name
    expect(drilldown).to have_school_urn school.urn
    expect(drilldown).to have_status participant_status
    expect(drilldown).to have_induction_status participant_status
    # TODO: is this correct?
    expect(drilldown).to be_eligible_for_funding
    expect(drilldown).to have_schedule schedule_identifier
    expect(drilldown).to have_schedule_identifier schedule_identifier
    expect(drilldown).to have_schedule_cohort start_year
    expect(drilldown).to have_training_programme programme_name
    expect(drilldown).to have_participant_class participant_class
  end
end
