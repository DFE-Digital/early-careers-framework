# frozen_string_literal: true

RSpec.describe ParticipantStatusTagComponent, type: :view_component do
  component { described_class.new profile: participant_profile }

  let!(:participant_profile) { create :ecf_participant_profile }

  context "when the request for details has not been sent yet" do
    it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacting for information") }
  end

  context "with a request for details email record" do
    let!(:email) { create :email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status }

    context "which has been successfully delivered" do
      let(:email_status) { :delivered }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacted for information") }
    end

    context "which has failed to be deliver" do
      let(:email_status) { Email::FAILED_STATUSES.sample }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Check email address") }
    end

    context "which is still pending" do
      let(:email_status) { :submitted }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacting for information") }
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
    end

    context "was a participant in early roll out" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, previous_participation: true, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start: ERO") }
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--orange", exact_text: "DfE checking eligibility") }
    end

    context "has a previous induction reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, previous_induction: true, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: NQT+1") }
    end

    context "has no QTS reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, qts: false, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: No QTS") }
    end

    context "has an ineligible status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile: participant_profile) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible") }
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) {  create(:ect_participant_profile, training_status: "withdrawn", school_cohort: school_cohort, user: create(:user, email: "ray.clemence@example.com")) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Withdrawn by provider") }
    end
  end
end
