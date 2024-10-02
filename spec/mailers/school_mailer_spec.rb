# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#remind_sit_that_ab_has_not_registered_ect" do
    let(:school) { create(:seed_school, :valid) }
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:ect_name) { "Neville Southall" }
    let(:appropriate_body_name) { "Super AB" }
    let(:lead_provider_name) { "Major Providers Ltd" }
    let(:delivery_partner_name) { "Amazing Delivery Inc." }

    let(:email) do
      SchoolMailer
        .with(school:, induction_coordinator:, ect_name:, appropriate_body_name:, lead_provider_name:, delivery_partner_name:)
        .remind_sit_that_ab_has_not_registered_ect
        .deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq([induction_coordinator.user.email])
    end

    it "has the correct personalisation" do
      personalisation = email[:personalisation].unparsed_value

      expect(personalisation[:school_name]).to eq school.name
      expect(personalisation[:sit_name]).to eq induction_coordinator.user.full_name
      expect(personalisation[:sit_email_address]).to eq induction_coordinator.user.email
      expect(personalisation[:ect_name]).to eq ect_name
      expect(personalisation[:lead_provider]).to eq lead_provider_name
      expect(personalisation[:delivery_partner]).to eq delivery_partner_name
      expect(personalisation[:appropriate_body_name]).to eq appropriate_body_name
    end

    context "when lead provider name is blank" do
      let(:lead_provider_name) { nil }

      it "uses Unconfirmed instead" do
        personalisation = email[:personalisation].unparsed_value
        expect(personalisation[:lead_provider]).to eq "Unconfirmed"
      end
    end

    context "when delivery partner name is blank" do
      let(:delivery_partner_name) { nil }

      it "uses Unconfirmed instead" do
        personalisation = email[:personalisation].unparsed_value
        expect(personalisation[:delivery_partner]).to eq "Unconfirmed"
      end
    end
  end

  describe "#remind_sit_to_appoint_ab_for_unregistered_ect" do
    let(:school) { create(:seed_school, :valid) }
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:ect_name) { "Sepp Maier" }
    let(:lead_provider_name) { "Major Providers Ltd" }
    let(:delivery_partner_name) { "Amazing Delivery Inc." }

    let(:email) do
      SchoolMailer
        .with(school:, induction_coordinator:, ect_name:, lead_provider_name:, delivery_partner_name:)
        .remind_sit_to_appoint_ab_for_unregistered_ect
        .deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq([induction_coordinator.user.email])
    end

    it "has the correct personalisation" do
      personalisation = email[:personalisation].unparsed_value

      expect(personalisation[:school_name]).to eq school.name
      expect(personalisation[:sit_name]).to eq induction_coordinator.user.full_name
      expect(personalisation[:email_address]).to eq induction_coordinator.user.email
      expect(personalisation[:ect_name]).to eq ect_name
      expect(personalisation[:lead_provider]).to eq lead_provider_name
      expect(personalisation[:delivery_partner]).to eq delivery_partner_name
    end

    context "when lead provider name is blank" do
      let(:lead_provider_name) { nil }

      it "uses Unconfirmed instead" do
        personalisation = email[:personalisation].unparsed_value
        expect(personalisation[:lead_provider]).to eq "Unconfirmed"
      end
    end

    context "when delivery partner name is blank" do
      let(:delivery_partner_name) { nil }

      it "uses Unconfirmed instead" do
        personalisation = email[:personalisation].unparsed_value
        expect(personalisation[:delivery_partner]).to eq "Unconfirmed"
      end
    end
  end

  describe "#notify_sit_we_have_archived_participant" do
    let(:school) { create(:seed_school, :valid) }
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:sign_in_url) { "https://ecf-dev.london.cloudapps" }
    let(:participant_name) { "Jessica Walnut" }
    let(:role) { "Early career teacher" }

    let(:email) do
      SchoolMailer
        .with(school:, induction_coordinator:, sign_in_url:, participant_name:, role:)
        .notify_sit_we_have_archived_participant
        .deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq([induction_coordinator.user.email])
    end

    it "has the correct personalisation" do
      personalisation = email[:personalisation].unparsed_value

      expect(personalisation[:school_name]).to eq school.name
      expect(personalisation[:sit_name]).to eq induction_coordinator.user.full_name
      expect(personalisation[:sit_email_address]).to eq induction_coordinator.user.email
      expect(personalisation[:participant_name]).to eq participant_name
      expect(personalisation[:role]).to eq role
      expect(personalisation[:sign_in]).to eq sign_in_url
    end
  end

  describe "#ask_gias_contact_to_validate_sit_details" do
    let(:school) { create(:seed_school, :valid, primary_contact_email: "mary.gias@example.com") }
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:start_page_url) { "https://ecf-dev.london.cloudapps" }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:email) do
      SchoolMailer.with(school:, induction_coordinator:, start_page_url:, nomination_link:).ask_gias_contact_to_validate_sit_details.deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq(["mary.gias@example.com"])
    end
  end

  describe "#remind_sit_to_assign_mentors_to_ects_email" do
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:school) { create(:seed_school) }

    let(:email) do
      SchoolMailer.with(induction_coordinator:, school:).remind_sit_to_assign_mentors_to_ects_email.deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq [induction_coordinator.user.email]
    end
  end

  describe "#remind_sit_to_add_ects_and_mentors_email" do
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:school) { create(:seed_school) }

    let(:email) do
      SchoolMailer.with(induction_coordinator:, school:).remind_sit_to_add_ects_and_mentors_email.deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq [induction_coordinator.user.email]
    end
  end

  describe "#cohortless_pilot_2023_survey_email" do
    let(:sit_user) { create(:seed_induction_coordinator_profile, :with_user).user }

    let(:email) do
      SchoolMailer.with(sit_user:).cohortless_pilot_2023_survey_email.deliver_now
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq [sit_user.email]
    end
  end

  describe "#nomination_email" do
    let!(:cohort) { Cohort.current || create(:cohort, :current) }
    let(:school) { instance_double School, name: "Great Ouse Academy" }
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:nomination_email) do
      SchoolMailer.with(
        recipient: primary_contact_email,
        nomination_url:,
        school:,
        expiry_date: "1/1/2000",
      ).nomination_email.deliver_now
    end

    it "renders the right headers" do
      expect(Cohort).to receive(:active_registration_cohort).and_return(cohort).once
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([primary_contact_email])
    end

    context "when the pilot is active", travel_to: Date.new(2023, 7, 1) do
      let!(:cohort_next) { Cohort.next || create(:cohort, :next) }

      it "renders the right headers" do
        expect(Cohort).to receive(:active_registration_cohort).and_return(cohort_next).once
        expect(nomination_email.from).to eq(["mail@example.com"])
        expect(nomination_email.to).to eq([primary_contact_email])
      end
    end
  end

  describe "#remind_to_update_school_induction_tutor_details" do
    let(:school) { instance_double School, name: "Great Ouse Academy", primary_contact_email: "hello@example.com", secondary_contact_email: "goodbye@example.com" }
    let(:sit_name) { "Mrs SIT" }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:nomination_email) do
      SchoolMailer.with(
        nomination_link:,
        school:,
        sit_name:,
      ).remind_to_update_school_induction_tutor_details.deliver_now
    end

    it "renders the right headers" do
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([school.primary_contact_email, school.secondary_contact_email])
    end
  end

  describe "#nomination_confirmation_email" do
    let(:school) { create(:school) }
    let(:sit_profile) { create(:induction_coordinator_profile) }
    let(:start_url) { "https://ecf-dev.london.cloudapps" }

    let(:nomination_confirmation_email) do
      SchoolMailer.with(
        email_address: sit_profile.user.email,
        sit_profile:,
        school:,
        start_url:,
        step_by_step_url: start_url,
      ).nomination_confirmation_email.deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([sit_profile.user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::NOMINATION_CONFIRMATION_EMAIL_TEMPLATE).to eq("7935cf72-75e9-4d0d-a05f-6f2ccda2b398")
    end
  end

  describe "#coordinator_partnership_notification_email" do
    let(:coordinator) { build_stubbed(:induction_coordinator_profile).user }
    let(:sign_in_url) { "https://www.example.com/sign-in" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }
    let(:partnership) { build_stubbed :partnership }

    let(:partnership_notification_email) do
      SchoolMailer.with(
        coordinator:,
        partnership:,
        sign_in_url:,
        challenge_url:,
      ).coordinator_partnership_notification_email
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([coordinator.email])
    end
  end

  describe "#school_partnership_notification_email" do
    let(:recipient) { Faker::Internet.email }
    let(:nominate_url) { "https://www.example.com?token=def456" }
    let(:challenge_url) { "https://www.example.com?token=abc123" }
    let(:partnership) { build_stubbed :partnership }

    let(:partnership_notification_email) do
      SchoolMailer.with(
        partnership:,
        recipient:,
        nominate_url:,
        challenge_url:,
      ).school_partnership_notification_email
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([recipient])
    end
  end

  describe "sit_fip_provider_has_withdrawn_a_participant" do
    let(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
    let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:, user: create(:user, email: "john.clemence@example.com")) }
    let(:sit_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }
    let(:partnership) { create(:partnership) }

    before do
      create(:induction_record, participant_profile:, partnership:)
    end

    let(:email) do
      SchoolMailer.with(
        withdrawn_participant: participant_profile,
        induction_coordinator: sit_profile,
        partnership:,
      ).fip_provider_has_withdrawn_a_participant
    end

    it "sets the right sender and recipient addresses" do
      aggregate_failures do
        expect(email.from).to eq(["mail@example.com"])
        expect(email.to).to eq([sit_profile.user.email])
      end
    end
  end

  describe "#pilot_ask_sit_to_report_school_training_details" do
    let(:sit_user) { create(:user, :induction_coordinator) }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:pilot_ask_sit_to_report_school_training_details) do
      SchoolMailer.with(
        sit_user:,
        nomination_link:,
        email_address: sit_user.email,
      ).pilot_ask_sit_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_ask_sit_to_report_school_training_details.to).to eq([sit_user.email])
      expect(pilot_ask_sit_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("87d4720b-9e3a-46d9-95de-493295dba1dc")
    end
  end

  describe "#pilot_ask_gias_contact_to_report_school_training_details" do
    let(:gias_contact_email) { "contact@example.com" }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:pilot_ask_gias_contact_to_report_school_training_details) do
      SchoolMailer.with(
        gias_contact_email:,
        nomination_link:,
      ).pilot_ask_gias_contact_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_ask_gias_contact_to_report_school_training_details.to).to eq([gias_contact_email])
      expect(pilot_ask_gias_contact_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("ae925ff1-edc3-4d5c-a120-baa3a79c73af")
    end
  end

  describe "#pilot_chase_sit_to_report_school_training_details" do
    let(:sit_user) { create(:user, :induction_coordinator) }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:pilot_chase_sit_to_report_school_training_details) do
      SchoolMailer.with(
        sit_user:,
        nomination_link:,
        email_address: sit_user.email,
      ).pilot_chase_sit_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_chase_sit_to_report_school_training_details.to).to eq([sit_user.email])
      expect(pilot_chase_sit_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("87d4720b-9e3a-46d9-95de-493295dba1dc")
    end
  end

  describe "#pilot_chase_gias_contact_to_report_school_training_details" do
    let(:school) { create(:school) }
    let(:gias_contact_email) { school.primary_contact_email }
    let(:opt_in_out_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:pilot_chase_gias_contact_to_report_school_training_details) do
      SchoolMailer.with(
        school:,
        gias_contact_email:,
        opt_in_out_link:,
      ).pilot_chase_gias_contact_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_chase_gias_contact_to_report_school_training_details.to).to eq([gias_contact_email])
      expect(pilot_chase_gias_contact_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("ae925ff1-edc3-4d5c-a120-baa3a79c73af")
    end
  end

  describe "#launch_ask_sit_to_report_school_training_details" do
    let(:sit_user) { create(:user, :induction_coordinator) }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:launch_ask_sit_to_report_school_training_details) do
      SchoolMailer.with(
        sit_user:,
        nomination_link:,
      ).launch_ask_sit_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(launch_ask_sit_to_report_school_training_details.to).to eq([sit_user.email])
      expect(launch_ask_sit_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::LAUNCH_ASK_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("1f796f27-9ba4-4705-a7c9-57462bd1e0b7")
    end
  end

  describe "#launch_ask_gias_contact_to_report_school_training_details" do
    let(:school) { create(:school) }
    let(:gias_contact_email) { school.primary_contact_email }
    let(:opt_in_out_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:launch_ask_gias_contact_to_report_school_training_details) do
      SchoolMailer.with(
        school:,
        gias_contact_email:,
        opt_in_out_link:,
      ).launch_ask_gias_contact_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(launch_ask_gias_contact_to_report_school_training_details.to).to eq([gias_contact_email])
      expect(launch_ask_gias_contact_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::LAUNCH_ASK_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("f4dfee2a-2cc3-4d32-97f9-8adca41343bf")
    end
  end

  describe "#finance_errors_with_the_nqt_plus_one_grant" do
    let(:sit_user) { create(:user, :induction_coordinator) }

    let(:finance_errors_with_the_nqt_plus_one_grant) do
      SchoolMailer.with(
        recipient_email: sit_user.email,
        school: sit_user.school,
      ).finance_errors_with_the_nqt_plus_one_grant.deliver_now
    end

    it "renders the right headers" do
      expect(finance_errors_with_the_nqt_plus_one_grant.to).to eq([sit_user.email])
      expect(finance_errors_with_the_nqt_plus_one_grant.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::FINANCE_ERRORS_WITH_THE_NQT_PLUS_ONE_GRANT).to eq("cd7cbbfc-f40e-47e6-9491-467d0e99140a")
    end
  end

  describe "#finance_errors_with_the_ecf_year_2_grant" do
    let(:sit_user) { create(:user, :induction_coordinator) }

    let(:finance_errors_with_the_ecf_year_2_grant) do
      SchoolMailer.with(
        recipient_email: sit_user.email,
        school: sit_user.school,
      ).finance_errors_with_the_ecf_year_2_grant.deliver_now
    end

    it "renders the right headers" do
      expect(finance_errors_with_the_ecf_year_2_grant.to).to eq([sit_user.email])
      expect(finance_errors_with_the_ecf_year_2_grant.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::FINANCE_ERRORS_WITH_THE_ECF_YEAR_2_GRANT).to eq("2324145f-b679-4c40-b64a-08b0c05990d5")
    end
  end

  describe "#finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version" do
    let(:sit_user) { create(:user, :induction_coordinator) }

    let(:finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version) do
      SchoolMailer.with(
        recipient_email: sit_user.email,
        school: sit_user.school,
      ).finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version.deliver_now
    end

    it "renders the right headers" do
      expect(finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version.to).to eq([sit_user.email])
      expect(finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::FINANCE_ERRORS_WITH_NQT_PLUS_ONE_AND_ECF_YEAR_2_SCHOOLS_VERSION).to eq("94bec423-027b-4cf4-a501-9de61dde4905")
    end
  end

  describe "#finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version" do
    let(:local_authority_email) { Faker::Internet.email }
    let(:local_authority_name) { "Test local authority" }

    let(:finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version) do
      SchoolMailer.with(
        local_authority_email:,
        local_authority_name:,
      ).finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version.deliver_now
    end

    it "renders the right headers" do
      expect(finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version.to).to eq([local_authority_email])
      expect(finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::FINANCE_ERRORS_WITH_NQT_PLUS_ONE_AND_ECF_YEAR_2_LOCAL_AUTHORITY_VERSION).to eq("9953ed6b-4853-4be2-9ac2-692f07906166")
    end
  end

  describe "#sit_pre_term_reminder_to_report_any_changes" do
    let(:induction_coordinator) { create(:seed_induction_coordinator_profile, :with_user) }
    let(:email_address) { induction_coordinator.user.email }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:sit_pre_term_reminder_to_report_any_changes) do
      SchoolMailer.with(
        induction_coordinator:,
        nomination_link:,
      ).sit_pre_term_reminder_to_report_any_changes.deliver_now
    end

    it "renders the right headers" do
      expect(sit_pre_term_reminder_to_report_any_changes.to).to eq([email_address])
      expect(sit_pre_term_reminder_to_report_any_changes.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::SIT_PRE_TERM_REMINDER_TO_REPORT_ANY_CHANGES).to eq("59983db6-678f-4a7d-9a3b-80bed4f6ef17")
    end
  end
end
