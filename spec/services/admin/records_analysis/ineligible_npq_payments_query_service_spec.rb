# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RecordsAnalysis::IneligibleNPQPaymentsQueryService, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  subject { Admin::RecordsAnalysis::IneligibleNPQPaymentsQueryService.call(NPQApplication) }

  context "Given a system with accepted applications and payments made" do
    let!(:accepted_application) { create(:npq_application, :accepted, npq_lead_provider:) }
    let!(:accepted_application_with_payment) do
      application = create(:npq_application, :eligible_for_funding, :accepted, npq_lead_provider:)
      participant_profile = application.profile

      create(:npq_participant_declaration, :paid, participant_profile:, cpd_lead_provider:)
      application
    end

    context "Given a system with rejected applications and payments made or payable" do
      let!(:rejected_application) do
        application = create(:npq_application, npq_lead_provider:)

        application.update_column(:lead_provider_approval_status, :rejected)
        application
      end
      let!(:rejected_application_with_payment) do
        application = create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:)
        participant_profile = application.profile

        create(:npq_participant_declaration, :paid, participant_profile:, cpd_lead_provider:)
        application.update_column(:lead_provider_approval_status, :rejected)
        application
      end
      let!(:rejected_application_with_payable) do
        application = create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:)
        participant_profile = application.profile

        create(:npq_participant_declaration, :payable, participant_profile:, cpd_lead_provider:)
        application.update_column(:lead_provider_approval_status, :rejected)
        application
      end

      it "includes applications with invalid applications" do
        expect(subject).to include rejected_application_with_payment
        expect(subject).to include rejected_application_with_payable
      end

      it "does not include applications that are valid" do
        expect(subject).not_to include accepted_application_with_payment
      end

      it "does not include applications that have no associated payments" do
        expect(subject).not_to include accepted_application
        expect(subject).not_to include rejected_application
      end
    end
  end
end
