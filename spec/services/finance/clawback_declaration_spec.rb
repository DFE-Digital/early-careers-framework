# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ClawbackDeclaration do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

  let(:participant_declaration) { create(:ect_participant_declaration, :paid, cpd_lead_provider:) }

  let!(:next_statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: 3.months.from_now) }

  subject { described_class.new(participant_declaration:) }

  describe "#call" do
    it "mutates state of delaration to awaiting_clawback" do
      expect { subject.call }.to change { participant_declaration.reload.state }.from("paid").to("awaiting_clawback")
    end

    it "creates correct clawback line item" do
      expect { subject.call }.to change { Finance::StatementLineItem.where(state: "awaiting_clawback", participant_declaration:, statement: next_statement).count }.by(1)
    end

    it "create a correct declaration state record" do
      participant_declaration

      expect {
        subject.call
      }.to change { DeclarationState.where(participant_declaration:, state: "awaiting_clawback").count }.by(1)
    end

    context "when declaration already clawed back" do
      before do
        subject.call
      end

      it "does not create a line item" do
        expect { subject.call }.to_not change { Finance::StatementLineItem.count }
      end

      it "attaches an error to the object" do
        subject.call

        expect(subject.errors[:participant_declaration]).to be_present
      end
    end

    %i[ineligible submitted eligible voided payable awaiting_clawback clawed_back].each do |state|
      context "when declaration cannot be clawed back as #{state}" do
        let(:participant_declaration) { create(:ect_participant_declaration, state, cpd_lead_provider:) }

        it "does not create a line item" do
          expect { subject.call }.to_not change { Finance::StatementLineItem.count }
        end

        it "attaches an error to the object" do
          subject.call

          expect(subject.errors[:participant_declaration]).to be_present
        end
      end
    end
  end
end
