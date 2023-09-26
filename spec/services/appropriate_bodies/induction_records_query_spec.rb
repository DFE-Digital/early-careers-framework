# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodies::InductionRecordsQuery do
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:partnership) do
    create(
      :partnership,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, appropriate_body:, induction_programme:) }
  let!(:another_induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

  subject { described_class.new(appropriate_body:) }

  describe "#induction_records" do
    it "returns latest induction record for appropriate body" do
      expect(subject.induction_records).to match_array([induction_record])
    end

    context "when there is an email associated with the participant that has a request_for_details tag" do
      before { create(:email, associated_with: [participant_profile], tags: %w[request_for_details]) }

      it "populates transient_latest_request_for_details_status with the email status" do
        expect(subject.induction_records.last).to have_attributes(transient_latest_request_for_details_status: "submitted")
      end
    end

    context "when there are historical mentees associated with the participant" do
      let(:participant_profile) { create(:mentor) }
      let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

      before { mentee.latest_induction_record.update!(induction_status: "completed") }

      it "populates transient_mentees with true" do
        expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
        expect(subject.induction_records.last).to have_attributes(transient_current_mentees: false)
      end
    end

    context "when there are current mentees associated with the participant" do
      let(:participant_profile) { create(:mentor) }
      let!(:mentee) { create(:ect, mentor_profile: participant_profile) }

      it "populates transient_current_mentees with true" do
        expect(subject.induction_records.last).to have_attributes(transient_current_mentees: true)
        expect(subject.induction_records.last).to have_attributes(transient_mentees: true)
      end
    end

    context "when there are more induction records for the same appropriate body" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, appropriate_body:, induction_programme:) }

      it "returns latest induction record for appropriate body" do
        expect(subject.induction_records).to match_array([latest_induction_record])
      end
    end

    context "when there are newer induction records for a different appropriate body" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "deferred") }

      it "returns correct induction record for appropriate body" do
        expect(subject.induction_records).to match_array([induction_record])
      end
    end
  end
end
