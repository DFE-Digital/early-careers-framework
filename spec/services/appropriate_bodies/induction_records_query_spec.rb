# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodies::InductionRecordsQuery do
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:mentor_profile) { create(:mentor_participant_profile) }
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
  let!(:mentor_induction_record) { create(:induction_record, participant_profile: mentor_profile, appropriate_body:, induction_programme:) }

  subject { described_class.new(appropriate_body:) }

  describe "#induction_records" do
    it_behaves_like "a query optimised for calculating training record states", mentor_optimization: false

    it "returns latest induction record for appropriate body" do
      expect(subject.induction_records).to match_array([induction_record])
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
