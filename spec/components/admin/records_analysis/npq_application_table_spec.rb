# frozen_string_literal: true

RSpec.describe Admin::RecordsAnalysis::NPQApplicationTable, :with_default_schedules, type: :component do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  let(:rejected_application_with_payment) { create(:npq_application, :accepted, eligible_for_funding: true, npq_lead_provider:) }
  let(:rejected_application_with_payable) { create(:npq_application, :accepted, eligible_for_funding: true, npq_lead_provider:) }

  let(:applications) { [rejected_application_with_payment, rejected_application_with_payable] }

  before do
    create(:npq_statement, :next_output_fee, cpd_lead_provider:)
    create(:npq_participant_declaration, :paid, participant_profile: rejected_application_with_payment.profile, cpd_lead_provider:)
    create(:npq_participant_declaration, :payable, participant_profile: rejected_application_with_payable.profile, cpd_lead_provider:)
    rejected_application_with_payment.update_column(:lead_provider_approval_status, :rejected)
    rejected_application_with_payable.update_column(:lead_provider_approval_status, :rejected)
  end

  let(:component) { described_class.new applications: }
  subject! { render_inline(component) }

  it "renders table row for each application" do
    expect(rendered_content).to have_css(".govuk-table__body > .govuk-table__row", count: applications.size)
  end
end
