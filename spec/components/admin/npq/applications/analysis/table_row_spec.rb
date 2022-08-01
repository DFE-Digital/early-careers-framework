# frozen_string_literal: true

RSpec.describe Admin::NPQ::Applications::Analysis::TableRow, type: :view_component do
  let!(:cohort) { create :cohort }
  let!(:schedule) { create :npq_leadership_schedule, cohort: }
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  let(:application) do
    npq_application = create(:npq_application, :rejected,
                             npq_lead_provider:,
                             npq_course:,
                             cohort:)

    participant_profile = create(:npq_participant_profile, npq_application:)

    create(:npq_participant_declaration,
           declaration_type: "started",
           user: npq_application.user,
           participant_profile:,
           cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
           course_identifier: npq_course.identifier,
           state: "paid")

    npq_application
  end

  component { described_class.new application: }

  it { is_expected.to have_content "Full name\n    #{application.user.full_name}" }
  it { is_expected.to have_link application.user.full_name, href: admin_participant_path(application.profile) }
  it { is_expected.to have_content "Application Status\n    rejected" }
  it { is_expected.to have_content npq_course.name }
  it { is_expected.to have_content "Last Declaration\n    started" }
  it { is_expected.to have_content "Lead Provider\n    #{npq_lead_provider.cpd_lead_provider.name}" }
  it { is_expected.to have_content "Status\n    paid" }
  it { is_expected.to have_content "Date\n    #{application.profile.participant_declarations.first.created_at.to_date.to_s(:govuk_short)}" }
end
