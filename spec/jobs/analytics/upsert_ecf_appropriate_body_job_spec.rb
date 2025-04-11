# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::UpsertECFAppropriateBodyJob do
  describe "#perform" do
    it "calls Analytics::ECFAppropriateBodyService.upsert_record when the appropriate body exists" do
      appropriate_body = create(:appropriate_body_local_authority)
      expect(Analytics::ECFAppropriateBodyService).to receive(:upsert_record).with(appropriate_body)

      described_class.new.perform(appropriate_body_id: appropriate_body.id)
    end

    it "does not call Analytics::ECFAppropriateBodyService.upsert_record when the appropriate body does not exist" do
      expect(Analytics::ECFAppropriateBodyService).not_to receive(:upsert_record)

      described_class.new.perform(appropriate_body_id: SecureRandom.uuid)
    end
  end
end
