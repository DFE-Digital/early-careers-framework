# frozen_string_literal: true

RSpec.describe StatusTags::AdminParticipantStatusTag, :with_training_record_state_examples, type: :component do
  subject { render_inline described_class.new(participant_profile:) }

  context "when the request for details has not been sent yet" do
    let(:participant_profile) { ect_on_fip_no_validation }
    it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacted for information") }
  end

  context "with a request for details email record" do
    context "which has been successfully delivered" do
      let(:participant_profile) { ect_on_fip_details_request_delivered }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacted for information") }
    end

    context "which has failed to be deliver" do
      let(:participant_profile) { ect_on_fip_details_request_failed }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Check email address") }
    end

    context "which is still pending" do
      let(:participant_profile) { ect_on_fip_details_request_submitted }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--grey", exact_text: "Contacted for information") }
    end
  end

  context "mentor with multiple profiles" do
    context "when the primary profile is eligible" do
      let(:participant_profile) { mentor_profile_duplicity_primary }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible: Mentor at main school") }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { mentor_profile_duplicity_secondary }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible: Mentor at additional school") }
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
    end

    context "was a participant in early roll out" do
      let(:participant_profile) { mentor_ineligible_previous_participation }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start: ERO") }
    end

    context "has a withdrawn status" do
      context "when there is not induction record to use" do
        let(:participant_profile) { ect_on_fip_withdrawn_no_induction_record }
        it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Withdrawn by provider") }
      end

      context "when an active induction record is available" do
        let(:participant_profile) { ect_on_fip_enrolled_after_withdraw }
        it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
      end
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip_no_tra_record }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--orange", exact_text: "DfE checking eligibility") }
    end

    context "has a previous induction reason" do
      let(:participant_profile) { ect_on_cip_ineligible_previous_induction }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: NQT+1") }
    end

    context "has no QTS reason" do
      let(:participant_profile) { ect_on_cip_manual_check_no_qts }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible: No QTS") }
    end

    context "has an ineligible status" do
      let(:participant_profile) { ect_on_cip_ineligible_previous_participation }
      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Not eligible") }
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      it { is_expected.to have_selector(".govuk-tag.govuk-tag--red", exact_text: "Withdrawn by provider") }

      context "when an active induction record is available" do
        let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
        let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

        let(:component) { described_class.new(participant_profile:, induction_record:) }

        it { is_expected.to have_selector(".govuk-tag.govuk-tag--green", exact_text: "Eligible to start") }
      end
    end
  end
end
