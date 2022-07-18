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
           course_identifier: npq_course.identifier,
           state: "paid")

    npq_application
  end

  component { described_class.new application: }

  it { is_expected.to have_link application.user.full_name, href: admin_participant_path(application.profile) }
  it { is_expected.to have_content application.created_at.to_date.to_s(:govuk_short) }
end
