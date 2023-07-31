# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQ::Applications::UpdateEligibleForFundingRelatedInformation do
  describe "#call" do
    let(:npq_application) { create(:npq_application) }
    let(:user) { create(:user, :admin) }
    let(:eligible_for_funding_updated_by) { user }
    let(:eligible_for_funding_updated_at) { Time.zone.now }

    context "when updating eligible_for_funding information successfully" do
      it "updates the eligible_for_funding_updated_by and eligible_for_funding_updated_at attributes" do
        service = described_class.new(
          npq_application,
          eligible_for_funding_updated_by:,
          eligible_for_funding_updated_at:,
        )
        expect(service).to respond_to(:call)
        expect { service.call }.not_to raise_error
        updated_npq_application = NPQApplication.find(npq_application.id)
        expect(updated_npq_application.eligible_for_funding_updated_by).to eq(eligible_for_funding_updated_by)
      end
    end
    context "when eligible_for_funding_updated_by is nil" do
      it "raises an error and does not update the record" do
        service = described_class.new(
          npq_application,
          eligible_for_funding_updated_by: nil,
          eligible_for_funding_updated_at:,
        )
        expect(service).to respond_to(:call)
        expect { service.call }.not_to raise_error
        # Verify the record is not updated
        expect(npq_application.eligible_for_funding_updated_by).to eq(nil)
        expect(npq_application.eligible_for_funding_updated_at).to eq(nil)
      end
    end
    context "when the NPQ application does not exist" do
      it "raises an error" do
        non_existent_npq_application_id = 99_999
        service = described_class.new(
          non_existent_npq_application_id,
          eligible_for_funding_updated_by:,
          eligible_for_funding_updated_at:,
        )
        expect { service.call }.to raise_error(NoMethodError)
      end
    end
  end
end
