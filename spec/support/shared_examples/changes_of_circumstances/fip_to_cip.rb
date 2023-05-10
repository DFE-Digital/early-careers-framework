# frozen_string_literal: true

RSpec.shared_examples "FIP to CIP" do |scenario, training_status|
  context "Then the Original SIT" do
    subject(:original_sit) { "Original SIT" }

    it Steps::ChangesOfCircumstanceSteps.then_sit_cannot_see_context(scenario),
       :aggregate_failures do
      then_sit_cannot_see_participant_in_school_portal subject
    end
  end

  context "Then the New SIT" do
    subject(:new_sit) { "New SIT" }

    it Steps::ChangesOfCircumstanceSteps.then_sit_can_see_context(scenario),
       :aggregate_failures do
      then_sit_can_see_participant_in_school_portal subject, scenario
    end

    # what are the onward actions available to the new school - can they do them ??
  end

  context "Then the Original Lead Provider" do
    subject(:original_lead_provider) { "Original Lead Provider" }

    it Steps::ChangesOfCircumstanceSteps.then_lead_provider_can_see_context(scenario, scenario.prior_declarations, training_status:, see_prior_school: true),
       :aggregate_failures do
      then_lead_provider_can_see_participant_in_api subject,
                                                    scenario,
                                                    scenario.prior_declarations,
                                                    training_status:,
                                                    see_prior_school: true
    end

    # previous lead provider can void ??
  end

  context "Then other Lead Providers" do
    subject(:another_lead_provider) { "Another Lead Provider" }

    it Steps::ChangesOfCircumstanceSteps.then_lead_provider_cannot_see_context(scenario),
       :aggregate_failures do
      then_lead_provider_cannot_see_participant_in_api subject, scenario
    end
  end

  context "Then the Support for Early Career Teachers Service" do
    subject(:support_ects) { "Support for Early Career Teachers Service" }

    it Steps::ChangesOfCircumstanceSteps.then_support_service_context(scenario),
       :aggregate_failures do
      then_ecf_users_endpoint_shows_the_current_record scenario
    end
  end

  context "Then a Teacher CPD Finance User" do
    subject(:finance_user) { "Teacher CPD Finance User" }

    it Steps::ChangesOfCircumstanceSteps.then_finance_user_context(scenario),
       :aggregate_failures do
      given_i_sign_in_as_a_finance_user

      then_the_finance_portal_shows_the_current_participant_record "The Participant",
                                                                   scenario.participant_type,
                                                                   "New SIT",
                                                                   "",
                                                                   "active",
                                                                   "active",
                                                                   scenario.all_declarations

      then_the_finance_portal_shows_the_lead_provider_payment_breakdown "Original Lead Provider",
                                                                        scenario.statement_name,
                                                                        scenario.original_payment_ects,
                                                                        scenario.original_payment_mentors,
                                                                        scenario.original_started_declarations,
                                                                        scenario.original_retained_declarations,
                                                                        0, 0

      then_the_finance_portal_shows_the_lead_provider_payment_breakdown "Another Lead Provider",
                                                                        scenario.statement_name,
                                                                        0, 0, 0, 0, 0, 0

      sign_out
    end
  end

  context "Then a Teacher CPD Admin User" do
    subject(:admin_user) { "Teacher CPD Admin User" }

    it Steps::ChangesOfCircumstanceSteps.then_admin_user_context(scenario),
       :aggregate_failures do
      then_admin_user_can_see_participant scenario
    end
  end

  context "Then the Analytics Dashboards" do
    subject(:analytics_user) { "Analysts" }

    it "is expected to report the correct participant details for \"The Participant\"",
       :aggregate_failures,
       skip: "Not yet implemented" do
      is_expected.to report_correct_participant_details "The Participant"
    end
  end
end
