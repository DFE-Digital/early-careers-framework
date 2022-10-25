# frozen_string_literal: true

RSpec.describe Admin::Participants::NPQValidationStatusTag, :with_default_schedules, type: :component do
  let(:component) { described_class.new profile: participant_profile }

  let!(:participant_profile) { create :npq_participant_profile }

  subject { render_inline(component) }

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
