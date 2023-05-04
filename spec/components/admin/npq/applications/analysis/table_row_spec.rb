# frozen_string_literal: true

RSpec.describe Admin::NPQ::Applications::Analysis::TableRow, :with_default_schedules, type: :component do
  let(:npq_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider).npq_lead_provider }
  let(:user) { create(:user, full_name: "John Doe") }
  let(:npq_application) do
    create(:npq_application, :funded, :accepted, npq_lead_provider:, user:)
  end

  before do
    create(:npq_participant_declaration,
           :paid,
           participant_profile: npq_application.profile,
           cpd_lead_provider: npq_lead_provider.cpd_lead_provider)
  end

  let(:component) { described_class.new application: npq_application }
  subject { render_inline(component) }

  it { is_expected.to have_content "Full name\n    #{npq_application.user.full_name}" }
  it { is_expected.to have_link npq_application.user.full_name, href: admin_participant_path(npq_application.profile) }
  it { is_expected.to have_content "Application Status\n    accepted" }
  it { is_expected.to have_content npq_application.npq_course.name }
  it { is_expected.to have_content "Last Declaration\n    started" }
  it { is_expected.to have_content "Lead Provider\n    #{npq_lead_provider.cpd_lead_provider.name}" }
  it { is_expected.to have_content "Status\n    paid" }
  it { is_expected.to have_content "Date\n    #{npq_application.profile.participant_declarations.first.created_at.to_date.to_fs(:govuk_short)}" }
end
