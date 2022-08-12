# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Reject do
  subject do
    described_class.new(npq_application:)
  end

  describe "#call" do
    let(:cohort_2021) { Cohort.current }
    let(:user) { create(:user) }
    let(:identity) { create(:participant_identity, user:) }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:npq_lead_provider) { create(:npq_lead_provider) }

    let(:npq_application) do
      NPQApplication.new(
        participant_identity: identity,
        npq_course:,
        npq_lead_provider:,
        cohort: cohort_2021,
      )
    end

    context "when application has already been accepted" do
      before do
        npq_application.lead_provider_approval_status = "accepted"
        npq_application.save!
      end

      it "cannot then be rejected" do
        subject.call
        expect(npq_application.reload).to be_accepted
        expect(npq_application.errors[:lead_provider_approval_status]).to be_present
      end
    end
  end
end
