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

  describe "#nomination_email_confirmation" do
    let(:school) { create(:school) }
    let(:sit_profile) { create(:induction_coordinator_profile) }
    let(:start_url) { "https://ecf-dev.london.cloudapps" }

    let(:nomination_confirmation_email) do
      SchoolMailer.with(
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
end
