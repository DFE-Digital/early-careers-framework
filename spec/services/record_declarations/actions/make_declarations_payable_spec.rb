# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPayable do
  let(:cutoff_date)                      { Time.zone.local(2021, 11, 1) }
  let(:before_cutoff_date)               { cutoff_date - 1.day }
  let(:after_cutoff_date)                { cutoff_date + 1.day }
  let(:eligible_before_start_date_count) { 3 }
  let(:submitted_after_end_date_count)   { 2 }
  let!(:ecf_declaration)                 { create(:ect_participant_declaration, :eligible, declaration_date: before_cutoff_date, created_at: before_cutoff_date) }
  let!(:npq_declaration)                 { create(:npq_participant_declaration, :eligible, declaration_date: before_cutoff_date, created_at: before_cutoff_date) }

  before do
    create_list(:ect_participant_declaration, submitted_after_end_date_count,   :submitted, declaration_date: after_cutoff_date, created_at: after_cutoff_date)
    create_list(:npq_participant_declaration, submitted_after_end_date_count,   :submitted, declaration_date: after_cutoff_date, created_at: after_cutoff_date)
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

    context "with a ParticipantDeclaration::NPQ type" do
      it "updates the declaration state", :aggregate_failures do
        expect(npq_declaration).to be_eligible
        expect(npq_declaration).not_to be_payable

        expect {
          described_class.call(declaration_class: ParticipantDeclaration::NPQ, cutoff_date: cutoff_date.to_formatted_s(:db))
        }.to change(ParticipantDeclaration.payable, :count).from(0).to(1)

        expect(npq_declaration.reload).not_to be_eligible
        expect(npq_declaration).to be_payable
      end
    end
  end
end
