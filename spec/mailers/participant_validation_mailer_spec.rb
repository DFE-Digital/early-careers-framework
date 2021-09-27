# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantValidationMailer, type: :mailer do
  let(:recipient) { Faker::Internet.email }
  let(:school_name) { Faker::Company.name }
  let(:start_url) { "https://www.example.com/participants/start-registration" }
  let(:research_url) { "https://www.example.com/pages/user-research" }

  describe "#ects_to_add_validation_information_email" do
    let(:induction_coordinator_email) do
      described_class.ects_to_add_validation_information_email(
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

  describe "#induction_coordinators_who_are_mentors_to_add_validation_information_email" do
    let(:email) do
      described_class.induction_coordinators_who_are_mentors_to_add_validation_information_email(
        recipient: recipient,
        school_name: school_name,
        start_url: "example.com/start-validation",
      )
    end

    it "renders the right headers" do
      expect(email.from).to match_array ["mail@example.com"]
      expect(email.to).to match_array [recipient]
    end
  end
end
