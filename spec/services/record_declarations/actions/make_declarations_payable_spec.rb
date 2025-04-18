# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPayable do
  let(:cpd_lead_provider)                { create(:cpd_lead_provider, :with_lead_provider) }
  let(:cutoff_date)                      { Time.zone.local(2021, 11, 1) }
  let(:before_cutoff_date)               { cutoff_date - 1.day }
  let(:after_cutoff_date)                { cutoff_date + 1.day }
  let(:eligible_before_start_date_count) { 3 }
  let(:submitted_after_end_date_count)   { 2 }
  let(:ecf_declaration) do
    travel_to before_cutoff_date do
      create(:ect_participant_declaration, :eligible, declaration_date: before_cutoff_date, cpd_lead_provider:)
    end
  end

  before do
    create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: cutoff_date)

    ecf_declaration

    travel_to after_cutoff_date do
      create_list(:ect_participant_declaration, submitted_after_end_date_count, :submitted, declaration_date: after_cutoff_date, cpd_lead_provider:)
    end
  end

  describe "#call" do
    context "with a ParticipantDeclaration::ECF type" do
      it "updates the declaration state", :aggregate_failures do
        expect(ecf_declaration).to be_eligible
        expect(ecf_declaration).not_to be_payable

        expect {
          described_class.call(declaration_class: ParticipantDeclaration::ECF, cutoff_date: cutoff_date.to_formatted_s(:db))
        }.to change(ParticipantDeclaration.payable, :count).from(0).to(1)

        expect(ecf_declaration.reload).not_to be_eligible
        expect(ecf_declaration).to be_payable
      end
    end
  end
end
