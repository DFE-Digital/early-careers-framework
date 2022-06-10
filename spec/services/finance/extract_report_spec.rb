# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ExtractReport, :with_default_schedules do
  def with_captured_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  describe "#npq" do
    let(:expected_headers) do
      %w[
        lead_provider_name
        school_urn
        eligible_for_funding
        school_name
        participant_id
        participant_trn
        application_id
        training_status
        training_status_reason
        course_identifier
        declaration_id
        declaration_date
        declaration_type
        declaration_updated_at
        declaration_state
        schedule_name
        statement
      ]
    end

    let!(:profile) { create(:npq_participant_profile) }
    let!(:user) { profile.user }
    let!(:cpd_lead_provider) { profile.npq_application.npq_lead_provider.cpd_lead_provider }
    let!(:statement) { create(:npq_statement, cpd_lead_provider:) }
    let!(:npq_course) { profile.npq_application.npq_course }
    let!(:declaration) do
      create(:npq_participant_declaration, user:, course_identifier: npq_course.identifier, participant_profile: profile, state: "payable")
    end
    let!(:line_item) do
      statement.statement_line_items.create!(
        state: "payable",
        participant_declaration: declaration,
      )
    end

    it "outputs headers to stdout" do
      output = with_captured_stdout { subject.npq }

      expect(output).to include(expected_headers.join(","))
    end

    it "outputs data to stdout" do
      output = with_captured_stdout { subject.npq }

      expect(output).to include(declaration.id)
    end
  end
end
