# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoidParticipantDeclaration do
  let(:start_date) { profile.schedule.milestones.first.start_date }
  let(:declaration_date) { start_date + 2.days }
  let(:profile) { create(:ect_participant_profile) }
  let(:school) { profile.school_cohort.school }
  let(:user) { profile.user }
  let(:cpd_lead_provider) { profile.school_cohort.school.partnerships[0].lead_provider.cpd_lead_provider }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  before do
    create(:partnership, school:)
  end

  describe "#call" do
    let(:participant_declaration) do
      create(
        :ect_participant_declaration,
        user:,
        cpd_lead_provider:,
        declaration_date:,
        participant_profile: profile,
      )
    end

    subject do
      described_class.new(participant_declaration:)
    end

    it "voids a participant declaration" do
      subject.call
      expect(participant_declaration.reload).to be_voided
    end

    it "does not void a voided declaration" do
      subject.call

      expect {
        subject.call
      }.to raise_error Api::Errors::InvalidTransitionError
    end

    context "when declaration is payable" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          user:,
          cpd_lead_provider:,
          declaration_date:,
          participant_profile: profile,
          state: "payable",
        )
      end

      it "can be voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
      end
    end

    context "when declaration is paid" do
      let!(:next_statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: 3.months.from_now) }
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          user:,
          cpd_lead_provider:,
          declaration_date:,
          participant_profile: profile,
          state: "paid",
        )
      end

      let(:cohort) { school_cohort.cohort }
      let(:school_cohort) { school.school_cohorts[0] }
      let(:partnership) { create(:partnership, school:, lead_provider:, cohort:) }
      let(:induction_programme) { create(:induction_programme, partnership:) }

      before do
        Induction::Enrol.call(participant_profile: profile, induction_programme:)
      end

      it "transitions to awaiting_clawback" do
        subject.call
        expect(participant_declaration.reload).to be_awaiting_clawback
      end
    end

    context "when declaration is submitted" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          user:,
          cpd_lead_provider:,
          declaration_date:,
          participant_profile: profile,
          state: "submitted",
        )
      end

      it "can be voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
      end
    end

    context "when declaration is attached to a statement" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          user:,
          cpd_lead_provider:,
          declaration_date:,
          participant_profile: profile,
          state: "payable",
        )
      end

      let!(:statement) do
        create(
          :ecf_statement,
          cpd_lead_provider:,
          output_fee: true,
          deadline_date: 3.months.from_now,
        )
      end

      let(:line_item) { participant_declaration.statement_line_items.first }

      before do
        Finance::StatementLineItem.create!(
          participant_declaration:,
          statement:,
          state: participant_declaration.state,
        )
      end

      it "update line item state to voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
        expect(line_item.reload).to be_voided
      end
    end
  end
end
