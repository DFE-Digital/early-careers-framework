# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartners::InductionRecordsQuery do
  let(:delivery_partner) { create(:delivery_partner) }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:partnership) do
    create(
      :partnership,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
      delivery_partner:,
    )
  end
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let!(:another_induction_record) { create(:induction_record, participant_profile:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

  subject { described_class.new(delivery_partner:) }

  describe "#induction_records" do
    it_behaves_like "a query optimised for calculating training record states"

    it "returns latest induction record for delivery partner" do
      expect(subject.induction_records).to match_array([induction_record])
    end

    context "when there are more induction records for the same delivery partner" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

      it "returns latest induction record for delivery partner" do
        expect(subject.induction_records).to match_array([latest_induction_record])
      end
    end

    context "when there are newer induction records for a different delivery partner" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, training_status: "deferred") }

      it "returns correct induction record for the delivery partner" do
        expect(subject.induction_records).to match_array([induction_record])
      end
    end
  end
end
