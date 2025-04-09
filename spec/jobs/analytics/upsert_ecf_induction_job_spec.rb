# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::UpsertECFInductionJob do
  describe "#perform" do
    it "calls Analytics::ECFInductionService.upsert_record when the induction record exists" do
      induction_record = create(:induction_record)
      expect(Analytics::ECFInductionService).to receive(:upsert_record).with(induction_record)

      described_class.new.perform(induction_record_id: induction_record.id)
    end

    it "does not call Analytics::ECFInductionService.upsert_record when the induction record does not exist" do
      expect(Analytics::ECFInductionService).not_to receive(:upsert_record)

      described_class.new.perform(induction_record_id: SecureRandom.uuid)
    end
  end
end
