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
  end
end
