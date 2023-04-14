# frozen_string_literal: true

RSpec.describe ParticipantStatusTagComponent, type: :component do
  let!(:participant_profile) { create :ect_participant_profile }
  let(:component) { described_class.new profile: participant_profile }
  subject { page }

  context "when the request for details has not been sent yet" do
    before { render_inline(component) }

    it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacting for information") }
  end

  context "with a request for details email record" do
    let!(:email) { create :email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status }

    context "which has been successfully delivered" do
      let(:email_status) { :delivered }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacted for information") }
    end

    context "which has failed to be deliver" do
      let(:email_status) { Email::FAILED_STATUSES.sample }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Check email address") }
    end

    context "which is still pending" do
      let(:email_status) { :submitted }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacting for information") }
    end
  end

  context "mentor with multiple profiles" do
    let(:school_cohort) { create(:school_cohort) }

    context "when the primary profile is eligible" do
      let(:participant_profile) { create(:mentor_participant_profile, :primary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      before do
        participant_profile.reload
        render_inline(component)
      end

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible: Mentor at main school") }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

      before do
        participant_profile.reload
        render_inline(component)
      end

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible: Mentor at additional school") }
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
    end

    context "was a participant in early roll out" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start: ERO") }
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--orange", exact_text: "DfE checking eligibility") }
    end

    context "has a previous induction reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: NQT+1") }
    end

    context "has no QTS reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: No QTS") }
    end

    context "has an ineligible status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile:) }

      subject! { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible") }
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
      let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }

      before { render_inline(component) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Withdrawn by provider") }

      context "when an active induction record is available" do
        let(:component) { described_class.new(profile: participant_profile, induction_record:) }

        before { render_inline(component) }

        it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
      end
    end
  end
end
