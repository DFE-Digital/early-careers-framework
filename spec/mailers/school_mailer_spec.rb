# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#nomination_email" do
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
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([primary_contact_email])
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

  describe "#cip_only_invite_email" do
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:cip_only_invite_email) do
      SchoolMailer.with(
        recipient: primary_contact_email,
        nomination_url:,
        school_name: "Great Ouse Academy",
      ).cip_only_invite_email.deliver_now
    end

    it "renders the right headers" do
      expect(cip_only_invite_email.from).to eq(["mail@example.com"])
      expect(cip_only_invite_email.to).to eq([primary_contact_email])
    end
  end

  describe "#section_41_invite_email" do
    let(:primary_contact_email) { "contact@example.com" }
    let(:nomination_url) { "https://ecf-dev.london.cloudapps/nominations?token=abc123" }

    let(:section_41_invite_email) do
      SchoolMailer.with(
        recipient: primary_contact_email,
        nomination_url:,
        school_name: "Great Ouse Academy",
      ).section_41_invite_email.deliver_now
    end

    it "renders the right headers" do
      expect(section_41_invite_email.from).to eq(["mail@example.com"])
      expect(section_41_invite_email.to).to eq([primary_contact_email])
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
      expect(SchoolMailer::NOMINATION_CONFIRMATION_EMAIL_TEMPLATE).to eq("7cc9b459-b088-4d5a-84c8-33a74993a2fc")
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

  describe "remind_fip_induction_coordinators_to_add_ects_and_mentors_email" do
    let(:induction_coordinator) { create(:induction_coordinator_profile) }
    let(:school_name) { Faker::Company.name }
    let(:campaign) { :remind_fip_sit_to_complete_steps }

    let(:reminder_email) do
      SchoolMailer.with(
        induction_coordinator:,
        campaign:,
        school_name:,
      ).remind_fip_induction_coordinators_to_add_ects_and_mentors_email
    end
    it "renders the right headers" do
      expect(reminder_email.from).to eq(["mail@example.com"])
      expect(reminder_email.to).to eq([induction_coordinator.user.email])
    end
  end

  describe "nqt_plus_one_sitless_invite" do
    let(:email) do
      SchoolMailer.with(
        recipient: "hello@example.com",
        start_url: "www.example.com",
      ).nqt_plus_one_sitless_invite.deliver_now
    end

    it "renders the right headers" do
      expect(email.to).to eq(["hello@example.com"])
      expect(email.from).to eq(["mail@example.com"])
    end
  end

  describe "nqt_plus_one_sit_invite" do
    let(:email) do
      SchoolMailer.with(
        school: create(:school),
        recipient: "hello@example.com",
        start_url: "www.example.com",
      ).nqt_plus_one_sit_invite.deliver_now
    end

    it "renders the right headers" do
      expect(email.to).to eq(["hello@example.com"])
      expect(email.from).to eq(["mail@example.com"])
    end
  end

  describe "sit_new_ambition_ects_and_mentors_added_email" do
    let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
    let(:school_name) { Faker::Company.name }
    let(:sign_in_url) { "https://www.example.com/sign-in" }

    let(:email) do
      SchoolMailer.with(
        induction_coordinator_profile:,
        sign_in_url:,
        school_name:,
      ).sit_new_ambition_ects_and_mentors_added_email
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq([induction_coordinator_profile.user.email])
    end
  end

  describe "sit_fip_provider_has_withdrawn_a_participant" do
    let(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
    let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:, user: create(:user, email: "john.clemence@example.com")) }
    let(:sit_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

    let(:email) do
      SchoolMailer.with(
        withdrawn_participant: participant_profile,
        induction_coordinator: sit_profile,
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
      ).pilot_ask_sit_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_ask_sit_to_report_school_training_details.to).to eq([sit_user.email])
      expect(pilot_ask_sit_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_ASK_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("87d4720b-9e3a-46d9-95de-493295dba1dc")
    end
  end

  describe "#pilot_ask_gias_contact_to_report_school_training_details" do
    let(:school) { create(:school) }
    let(:gias_contact_email) { school.primary_contact_email }
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:pilot_ask_gias_contact_to_report_school_training_details) do
      SchoolMailer.with(
        school:,
        gias_contact_email:,
        nomination_link:,
      ).pilot_ask_gias_contact_to_report_school_training_details.deliver_now
    end

    it "renders the right headers" do
      expect(pilot_ask_gias_contact_to_report_school_training_details.to).to eq([gias_contact_email])
      expect(pilot_ask_gias_contact_to_report_school_training_details.from).to eq(["mail@example.com"])
    end

    it "uses the correct Notify template" do
      expect(SchoolMailer::PILOT_ASK_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE).to eq("ae925ff1-edc3-4d5c-a120-baa3a79c73af")
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
    let(:nomination_link) { "https://ecf-dev.london.cloudapps/nominations/start?token=123" }

    let(:launch_ask_gias_contact_to_report_school_training_details) do
      SchoolMailer.with(
        school:,
        gias_contact_email:,
        nomination_link:,
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
end
