# frozen_string_literal: true

RSpec.describe StatusTags::AppropriateBodyParticipantStatusTag, type: :component do
  let(:component) { described_class.new participant_profile:, induction_record: }

  subject { render_inline(component) }

  let(:appropriate_body) { create(:appropriate_body_local_authority) }
  let(:participant_profile) { create :ect_participant_profile }
  let!(:induction_record) { create :induction_record, participant_profile: }

  context "when the request for details has not been sent yet" do
    it { is_expected.to have_text("Contacted for information") }
  end

  context "with a request for details email record" do
    let!(:email) { create :email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status }

    context "which has been successfully delivered" do
      let(:email_status) { :delivered }

      it { is_expected.to have_text("Contacted for information") }
    end

    context "which has failed to be deliver" do
      let(:email_status) { Email::FAILED_STATUSES.sample }

      it { is_expected.to have_text("Contacted for information") }
    end

    context "which is still pending" do
      let(:email_status) { :submitted }

      it { is_expected.to have_text("Contacted for information") }
    end
  end

  context "mentor with multiple profiles" do
    let(:school_cohort) { create(:school_cohort) }

    before do
      participant_profile.reload
    end

    context "when the primary profile is eligible" do
      let(:participant_profile) { create(:mentor_participant_profile, :primary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile:) }

      it { is_expected.to have_text("Training or eligible for training") }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

      it { is_expected.to have_text("Training or eligible for training") }
    end

    context "when participant is Mentor and Induction Tutor", skip: "relating to AB table row only" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let(:induction_coordinator_profile) { create(:induction_coordinator_profile, user: participant_profile.user) }

      it { is_expected.to have_text("Mentor") }
    end
  end

  context "full induction programme participant" do
    let(:school_cohort) { create(:school_cohort, :fip) }

    context "has submitted validation data" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      it { is_expected.to have_text("Training or eligible for training") }
    end

    context "was a participant in early roll out" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

      it { is_expected.to have_text("Training or eligible for training") }
    end
  end

  context "core induction programme participant" do
    let(:school_cohort) { create(:school_cohort, :cip) }

    context "has submitted validation data" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile:) }

      it { is_expected.to have_text("DfE checking eligibility") }
    end

    context "has a previous induction reason" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

      it { is_expected.to have_text("Not eligible for funded training") }
    end

    context "has no QTS reason" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

      it { is_expected.to have_text("Checking QTS") }
    end

    context "has an ineligible status" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile:) }

      it { is_expected.to have_text("Not eligible") }
    end

    context "has a withdrawn status" do
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
      let!(:induction_record) { create(:induction_record, training_status: "withdrawn", participant_profile:) }

      it { is_expected.to have_text("No longer being trained") }
    end
  end
end
