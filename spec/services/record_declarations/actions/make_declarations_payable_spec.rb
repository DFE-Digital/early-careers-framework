# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPayable do
  let(:submission_time)                  { Time.zone.local(2021, 9, 30) }
  let(:start_date)                       { Time.zone.local(2021, 9, 1) }
  let(:end_date)                         { Time.zone.local(2021, 11, 1) }
  let(:before_start_date)                { start_date - 1.day }
  let(:after_end_date)                   { end_date + 1.day }
  let(:eligible_before_start_date_count) { 3 }
  let(:submitted_after_end_date_count)   { 2 }
  let!(:ecf_declaration)                 { create(:ect_participant_declaration, :eligible, declaration_date: submission_time, created_at: submission_time) }
  let!(:npq_declaration)                 { create(:npq_participant_declaration, :eligible, declaration_date: submission_time, created_at: submission_time) }

  before do
    create_list(:ect_participant_declaration, eligible_before_start_date_count, :eligible,  declaration_date: before_start_date, created_at: before_start_date)
    create_list(:ect_participant_declaration, submitted_after_end_date_count,   :submitted, declaration_date: after_end_date,    created_at: after_end_date)
    create_list(:npq_participant_declaration, eligible_before_start_date_count, :eligible,  declaration_date: before_start_date, created_at: before_start_date)
    create_list(:npq_participant_declaration, submitted_after_end_date_count,   :submitted, declaration_date: after_end_date,    created_at: after_end_date)
  end

  describe "#call" do
    context "with a ParticipantDeclaration::ECF type" do
      it "updates the declaration state", :aggregate_failures do
        expect(ecf_declaration).to be_eligible
        expect(ecf_declaration).not_to be_payable

        expect {
          described_class.call(declaration_class: ParticipantDeclaration::ECF, start_date: start_date.to_s(:db), end_date: end_date.to_s(:db))
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
          described_class.call(declaration_class: ParticipantDeclaration::NPQ, start_date: start_date.to_s(:db), end_date: end_date.to_s(:db))
        }.to change(ParticipantDeclaration.payable, :count).from(0).to(1)

        expect(npq_declaration.reload).not_to be_eligible
        expect(npq_declaration).to be_payable
      end
    end
  end
end
