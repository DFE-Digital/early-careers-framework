# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantValidationMailer, type: :mailer do
  let(:recipient) { Faker::Internet.email }
  let(:school_name) { Faker::Company.name }
  let(:start_url) { "https://www.example.com/participants/start-registration" }
  let(:research_url) { "https://www.example.com/pages/user-research" }

  describe "#ect_email" do
    let(:participant_validation_ect_email) do
      described_class.ect_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(participant_validation_ect_email.from).to match_array ["mail@example.com"]
      expect(participant_validation_ect_email.to).to match_array [recipient]
    end
  end

  describe "#ect_ur_email" do
    let(:participant_validation_ect_email) do
      described_class.ect_ur_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
        user_research_url: research_url,
      )
    end

    it "renders the right headers" do
      expect(participant_validation_ect_email.from).to match_array ["mail@example.com"]
      expect(participant_validation_ect_email.to).to match_array [recipient]
    end
  end

  describe "#fip_mentor_email" do
    let(:fip_mentor_email) do
      described_class.fip_mentor_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(fip_mentor_email.from).to match_array ["mail@example.com"]
      expect(fip_mentor_email.to).to match_array [recipient]
    end
  end

  describe "#fip_mentor_ur_email" do
    let(:fip_mentor_email) do
      described_class.fip_mentor_ur_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
        user_research_url: research_url,
      )
    end

    it "renders the right headers" do
      expect(fip_mentor_email.from).to match_array ["mail@example.com"]
      expect(fip_mentor_email.to).to match_array [recipient]
    end
  end

  describe "#cip_mentor_email" do
    let(:cip_mentor_email) do
      described_class.cip_mentor_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(cip_mentor_email.from).to match_array ["mail@example.com"]
      expect(cip_mentor_email.to).to match_array [recipient]
    end
  end

  describe "#engage_beta_mentor_email" do
    let(:engage_beta_mentor_email) do
      described_class.engage_beta_mentor_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(engage_beta_mentor_email.from).to match_array ["mail@example.com"]
      expect(engage_beta_mentor_email.to).to match_array [recipient]
    end
  end

  describe "#induction_coordinator_email" do
    let(:induction_coordinator_email) do
      described_class.induction_coordinator_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(induction_coordinator_email.from).to match_array ["mail@example.com"]
      expect(induction_coordinator_email.to).to match_array [recipient]
    end
  end

  describe "#induction_coordinator_check_ect_and_mentor_email" do
    let(:induction_coordinator_email) do
      described_class.induction_coordinator_check_ect_and_mentor_email(
        recipient: recipient,
        sign_in: "example.com/sign-in",
        step_by_step: "example.com/step-by-step",
        resend_email: "example.com/resend-email",
      )
    end

    it "renders the right headers" do
      expect(induction_coordinator_email.from).to match_array ["mail@example.com"]
      expect(induction_coordinator_email.to).to match_array [recipient]
    end
  end

  describe "#we_need_information_for_your_programme_email" do
    let(:induction_coordinator_email) do
      described_class.we_need_information_for_your_programme_email(
        recipient: recipient,
        school_name: school_name,
        start_url: "example.com/start-validation",
      )
    end

    it "renders the right headers" do
      expect(induction_coordinator_email.from).to match_array ["mail@example.com"]
      expect(induction_coordinator_email.to).to match_array [recipient]
    end
  end

  describe "#induction_coordinator_ur_email" do
    let(:induction_coordinator_email) do
      described_class.induction_coordinator_ur_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(induction_coordinator_email.from).to match_array ["mail@example.com"]
      expect(induction_coordinator_email.to).to match_array [recipient]
    end
  end

  describe "#coordinator_and_mentor_email" do
    let(:coordinator_and_mentor_email) do
      described_class.coordinator_and_mentor_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
      )
    end

    it "renders the right headers" do
      expect(coordinator_and_mentor_email.from).to match_array ["mail@example.com"]
      expect(coordinator_and_mentor_email.to).to match_array [recipient]
    end
  end

  describe "#coordinator_and_mentor_ur_email" do
    let(:coordinator_and_mentor_email) do
      described_class.coordinator_and_mentor_ur_email(
        recipient: recipient,
        school_name: school_name,
        start_url: start_url,
        user_research_url: research_url,
      )
    end

    it "renders the right headers" do
      expect(coordinator_and_mentor_email.from).to match_array ["mail@example.com"]
      expect(coordinator_and_mentor_email.to).to match_array [recipient]
    end
  end
end
