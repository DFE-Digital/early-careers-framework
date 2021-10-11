# frozen_string_literal: true

RSpec.describe ParticipantStatusTagComponent, type: :view_component do
  component { described_class.new profile: participant_profile }

  let!(:participant_profile) { create :participant_profile, :ecf }

  context "when the request for details has not been sent yet" do
    it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE to request details from participant") }
  end

  context "with a request for details email record" do
    let!(:email) { create :email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status }

    context "which has been successfully delivered" do
      let(:email_status) { :delivered }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--yellow", text: "DfE requested details from participant") }
    end

    context "which has failed to be deliver" do
      let(:email_status) { Email::FAILED_STATUSES.sample }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", text: "Could not contact: check email address") }
    end

    context "which is still pending" do
      let(:email_status) { :submitted }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--blue", text: "DfE to request details from participant") }
    end
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
