# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMailer, type: :mailer do
  describe "#nomination_email" do
    let(:school) { create :school }
    let(:primary_contact_email) { "contact@example.com" }
    let(:access_token) { SchoolAccessToken.create(school: school, permitted_actions: %i[some_action]) }

    let(:nomination_email) do
      SchoolMailer.nomination_email(
        recipient: primary_contact_email,
        school: school,
        access_token: access_token,
      )
    end

    it "renders the right headers" do
      expect(nomination_email.from).to eq(["mail@example.com"])
      expect(nomination_email.to).to eq([primary_contact_email])
    end
  end

  describe "#cip_only_invite_email" do
    let(:primary_contact_email) { "contact@example.com" }

    let(:cip_only_invite_email) do
      SchoolMailer.cip_only_invite_email(
        recipient: primary_contact_email,
        school_name: "Great Ouse Academy",
        access_token: create(:school_access_token),
      ).deliver_now
    end

    it "renders the right headers" do
      expect(cip_only_invite_email.from).to eq(["mail@example.com"])
      expect(cip_only_invite_email.to).to eq([primary_contact_email])
    end
  end

  describe "#section_41_invite_email" do
    let(:primary_contact_email) { "contact@example.com" }

    let(:section_41_invite_email) do
      SchoolMailer.section_41_invite_email(
        recipient: primary_contact_email,
        access_token: create(:school_access_token),
        school_name: "Great Ouse Academy",
      ).deliver_now
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
      SchoolMailer.nomination_confirmation_email(
        sit_profile: sit_profile,
        school: school,
        start_url: start_url,
        step_by_step_url: start_url,
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([sit_profile.user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end
  end

  describe "#coordinator_partnership_notification_email" do
    let!(:coordinator) { create(:induction_coordinator_profile, schools: [partnership.school]).user }
    let(:partnership) { create :partnership }

    let(:partnership_notification_email) do
      SchoolMailer.coordinator_partnership_notification_email(
        partnership: partnership,
        access_token: create(:school_access_token),
      )
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([coordinator.email])
    end
  end

  describe "#school_partnership_notification_email" do
    let(:partnership) { create :partnership }

    let(:partnership_notification_email) do
      SchoolMailer.school_partnership_notification_email(
        partnership: partnership,
        access_token: create(:school_access_token),
      )
    end

    it "renders the right headers" do
      expect(partnership_notification_email.from).to eq(["mail@example.com"])
      expect(partnership_notification_email.to).to eq([partnership.school.contact_email])
    end
  end

  describe "remind_fip_induction_coordinators_to_add_ects_and_mentors_email" do
    let(:induction_coordinator) { create(:induction_coordinator_profile) }
    let(:school_name) { Faker::Company.name }
    let(:campaign) { :remind_fip_sit_to_complete_steps }

    let(:reminder_email) do
      SchoolMailer.remind_fip_induction_coordinators_to_add_ects_and_mentors_email(
        induction_coordinator: induction_coordinator,
        campaign: campaign,
        school_name: school_name,
      )
    end
    it "renders the right headers" do
      expect(reminder_email.from).to eq(["mail@example.com"])
      expect(reminder_email.to).to eq([induction_coordinator.user.email])
    end
  end

  describe "nqt_plus_one_sitless_invite" do
    let(:email) do
      SchoolMailer.nqt_plus_one_sitless_invite(
        recipient: "hello@example.com",
        start_url: "www.example.com",
      ).deliver_now
    end

    it "renders the right headers" do
      expect(email.to).to eq(["hello@example.com"])
      expect(email.from).to eq(["mail@example.com"])
    end
  end

  describe "nqt_plus_one_sit_invite" do
    let(:email) do
      SchoolMailer.nqt_plus_one_sit_invite(
        school: create(:school),
        recipient: "hello@example.com",
        start_url: "www.example.com",
      ).deliver_now
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
      SchoolMailer.sit_new_ambition_ects_and_mentors_added_email(
        induction_coordinator_profile: induction_coordinator_profile,
        sign_in_url: sign_in_url,
        school_name: school_name,
      )
    end

    it "renders the right headers" do
      expect(email.from).to eq(["mail@example.com"])
      expect(email.to).to eq([induction_coordinator_profile.user.email])
    end
  end
end
