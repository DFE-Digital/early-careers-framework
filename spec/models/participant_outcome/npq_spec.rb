# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcome::NPQ, type: :model do
  describe "associations" do
    it {
      is_expected.to belong_to(:participant_declaration)
        .class_name("ParticipantDeclaration::NPQ")
    }
    it { is_expected.to have_many(:participant_outcome_api_requests) }
  end

  describe "state" do
    it {
      is_expected.to define_enum_for(:state).with_values(
        passed: "passed",
        failed: "failed",
        voided: "voided",
      ).backed_by_column_of_type(:string)
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:completion_date) }
  end
end
