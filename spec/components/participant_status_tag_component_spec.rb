# frozen_string_literal: true

RSpec.describe ParticipantStatusTagComponent, type: :view_component do
  component { described_class.new profile: participant_profile }

  let!(:participant_profile) { create :participant_profile, :ecf }

  context "when the participant hasn't submitted validation details" do
    it { is_expected.to have_selector(".govuk-tag.govuk-tag--yellow", text: "DfE requested details from participant") }
  end

  context "when the participant has submitted validation data" do
    let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: participant_profile) }

    it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE checking eligibility") }

    context "for an admin" do
      component { described_class.new profile: participant_profile, admin: true }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--turquoise", text: "Manual checks needed") }
    end

    context "when the details have been matched" do
      before do
        eligibility = ECFParticipantEligibility.create!(participant_profile: participant_profile)
        eligibility.matched_status!
      end

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE checking eligibility") }

      context "for an admin" do
        component { described_class.new profile: participant_profile, admin: true }

        it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE checking eligibility") }
      end
    end
  end

  context "when the participant is in manual check" do
    before do
      create(:ecf_participant_validation_data, participant_profile: participant_profile)
      eligibility = ECFParticipantEligibility.create!(participant_profile: participant_profile)
      eligibility.manual_check_status!
    end

    it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE checking eligibility") }

    context "for an admin" do
      component { described_class.new profile: participant_profile, admin: true }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--turquoise", text: "Manual checks needed") }
    end
  end
end
