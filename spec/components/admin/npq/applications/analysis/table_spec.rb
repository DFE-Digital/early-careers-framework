# frozen_string_literal: true

RSpec.describe Admin::NPQ::Applications::Analysis::Table, type: :view_component do
  let!(:cohort) { create :cohort }
  let!(:schedule) { create :npq_leadership_schedule, cohort: }
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  let(:rejected_application_with_payment) do
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
  let(:rejected_application_with_payable) do
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
           state: "payable")

    npq_application
  end

  let(:applications) { [rejected_application_with_payment, rejected_application_with_payable] }

  component { described_class.new applications: }
  request_path "/admin/npq/applications/analysis"

  stub_component Admin::NPQ::Applications::Analysis::TableRow

  it "renders table row for each application" do
    applications.each do |application|
      expect(rendered).to have_rendered(Admin::NPQ::Applications::Analysis::TableRow).with(application:)
    end
  end
end
