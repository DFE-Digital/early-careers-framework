# frozen_string_literal: true

RSpec.describe Admin::Participants::ValidationStatusTag, type: :view_component do
  component { described_class.new profile: participant_profile }

  context "for ECT profile" do
    let!(:participant_profile) { create :participant_profile, :ect }

    it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", text: "Not ready") }
  end

  context "for Mentor profile" do
    let!(:participant_profile) { create :participant_profile, :mentor }

    it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", text: "Not ready") }
  end

  context "for NPQ profile" do
    let!(:participant_profile) { create :participant_profile, :npq }

    context "when profile is approved" do
      before { allow(participant_profile).to receive(:approved?).and_return true }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", text: "Complete") }
    end

    context "when profile is rejected" do
      before { allow(participant_profile).to receive(:rejected?).and_return true }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", text: "Rejected") }
    end

    context "when profile is neither rejected nor approved" do
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--yellow", text: "Pending") }
    end
  end
end
