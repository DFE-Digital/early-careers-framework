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

  subject { described_class.new(appropriate_body:) }

  describe "#induction_records" do
    before do
      # Later induction record for different appropriate body (should be ignored)
      create(:induction_record, :with_end_date, participant_profile:, induction_programme:)

      # Mentor for same appropriate body (should be excluded)
      mentor_profile = create(:mentor_participant_profile)
      create(:induction_record, participant_profile: mentor_profile, appropriate_body:, induction_programme:)

      create(:induction_record, :with_end_date, participant_profile:, appropriate_body:, induction_programme:)
    end

    it_behaves_like "a query optimised for calculating training record states", mentor_optimization: false

    context "when the last induction record is linked to the appropriate body" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, appropriate_body:, induction_programme:) }

      it "returns latest induction record for appropriate body" do
        expect(subject.induction_records).to match_array([latest_induction_record])
      end
    end

    context "when there are newer induction records for a different appropriate body" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "deferred") }

      it "returns no induction record for appropriate body" do
        expect(subject.induction_records).to be_empty
      end
    end
  end
end
