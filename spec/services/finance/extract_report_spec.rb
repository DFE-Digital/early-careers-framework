# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ExtractReport do
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

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:statement) { create(:npq_statement, :next_output_fee, cpd_lead_provider:) }
    let!(:declaration) do
      travel_to statement.deadline_date do
        create(:npq_participant_declaration, :payable)
      end
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
