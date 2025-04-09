# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::UpsertECFPartnershipJob do
  describe "#perform" do
    it "calls Analytics::ECFPartnershipService.upsert_record when the partnership exists" do
      partnership = create(:partnership)
      expect(Analytics::ECFPartnershipService).to receive(:upsert_record).with(partnership)

      described_class.new.perform(partnership_id: partnership.id)
    end

    it "does not call Analytics::ECFPartnershipService.upsert_record when the partnership does not exist" do
      expect(Analytics::ECFPartnershipService).not_to receive(:upsert_record)

      described_class.new.perform(partnership_id: SecureRandom.uuid)
    end
  end
end
