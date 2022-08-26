# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Ehco::TargetedDeliveryFundingEligibilityUpdater do
  subject { described_class.run }

  let(:ehco_course) { create(:npq_ehco_course) }

  let(:applicable_application_hash) do
    {
      npq_course: ehco_course,
      targeted_delivery_funding_eligibility: true,
      created_at: described_class::REOPEN_DATE + 1.day,
    }
  end

  let!(:application_with_targeted_funding_set)     { create(:npq_application, applicable_application_hash) }
  let!(:application_with_targeted_funding_set_two) { create(:npq_application, applicable_application_hash) }
  let!(:application_before_cutoff)                 { create(:npq_application, applicable_application_hash.merge(created_at: described_class::REOPEN_DATE - 1.day)) }
  let!(:application_wrong_course)                  { create(:npq_application, applicable_application_hash.merge(npq_course: create(:npq_leadership_course))) }
  let!(:application_not_marked_for_funding)        { create(:npq_application, applicable_application_hash.merge(targeted_delivery_funding_eligibility: false)) }

  it "updates the targeted_delivery_funding_eligibility flag for applicable records" do
    expect { subject }.to change {
      [
        application_with_targeted_funding_set,
        application_with_targeted_funding_set_two,
      ].each(&:reload).map(&:targeted_delivery_funding_eligibility)
    }.from([true, true]).to([false, false])
  end

  it "does not update the targeted_delivery_funding_eligibility flag for inapplicable records" do
    expect { subject }.to_not change {
      [
        application_before_cutoff,
        application_wrong_course,
        application_not_marked_for_funding,
      ].each(&:reload).map(&:targeted_delivery_funding_eligibility)
    }
  end
end
