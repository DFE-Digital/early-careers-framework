# frozen_string_literal: true

RSpec.describe DeliveryPartners::Participants::TableRow, type: :view_component do
  component { described_class.new participant_profile: participant_profile, delivery_partner: delivery_partner }

  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school: school) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:partnership) do
    create(
      :partnership,
      school: school,
      delivery_partner: delivery_partner,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let!(:participant_profile) { create :ecf_participant_profile }
  let!(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }

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

    context "when the primary profile is eligible" do
      let(:participant_profile) { create(:mentor_participant_profile, :primary_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile: participant_profile) }

      before do
        participant_profile.reload
      end

      it { is_expected.to have_text("Training or eligible for training") }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile: participant_profile) }

      before do
        participant_profile.reload
      end

      it { is_expected.to have_text("Training or eligible for training") }
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile: participant_profile) }

      it { is_expected.to have_text("Training or eligible for training") }
    end

    context "was a participant in early roll out" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, previous_participation: true, participant_profile: participant_profile) }

      it { is_expected.to have_text("Training or eligible for training") }
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile: participant_profile) }

      it { is_expected.to have_text("DfE checking eligibility") }
    end

    context "has a previous induction reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, previous_induction: true, participant_profile: participant_profile) }

      it { is_expected.to have_text("Not eligible for funded training") }
    end

    context "has no QTS reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, qts: false, participant_profile: participant_profile) }

      it { is_expected.to have_text("Checking QTS") }
    end

    context "has an ineligible status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile: participant_profile) }

      it { is_expected.to have_text("Not eligible") }
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort: school_cohort, user: create(:user, email: "ray.clemence@example.com")) }

      it { is_expected.to have_text("No longer being trained") }
    end
  end
end
