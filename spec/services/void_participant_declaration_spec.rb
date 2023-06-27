# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoidParticipantDeclaration do
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:school) { participant_profile.school_cohort.school }

  let!(:statement) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      output_fee: true,
      deadline_date: 3.months.from_now,
    )
  end

  describe "#call" do
    let(:participant_declaration) do
      create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
    end

    subject do
      described_class.new(participant_declaration)
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
          :payable,
          cpd_lead_provider:,
          participant_profile:,
        )
      end

      it "can be voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
      end
    end

    context "when declaration is paid" do
      let(:participant_declaration) do
        create(
          :ect_participant_declaration,
          :paid,
          participant_profile:,
          cpd_lead_provider:,
        )
      end

      it "delegates to Finance::ClawbackDeclaration" do
        mock_service = instance_double(Finance::ClawbackDeclaration)

        allow(Finance::ClawbackDeclaration).to receive(:new).with(participant_declaration).and_return(mock_service)
        allow(mock_service).to receive(:call)
        allow(mock_service).to receive(:errors).and_return([])

        subject.call

        expect(mock_service).to have_received(:call)
      end
    end

    context "when declaration is submitted" do
      let(:participant_declaration) do
        create(:ect_participant_declaration, cpd_lead_provider:, participant_profile:)
      end

      before do
        create(:ecf_statement, :output_fee, cpd_lead_provider:, deadline_date: 3.months.from_now)
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
          :payable,
          cpd_lead_provider:,
          participant_profile:,
        )
      end

      let(:line_item) { participant_declaration.statement_line_items.first }

      it "updates declaration and line item state to voided" do
        subject.call
        expect(participant_declaration.reload).to be_voided
        expect(line_item.reload).to be_voided
      end
    end

    context "when NPQ completed declaration thats paid" do
      let(:schedule) { NPQCourse.schedule_for(npq_course:) }
      let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date }
      let(:npq_course) { create(:npq_leadership_course) }
      let(:declaration_type) { "completed" }
      let(:participant_profile) do
        create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:)
      end
      let(:participant_declaration) do
        travel_to declaration_date do
          create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:, declaration_type:, declaration_date:, state: "paid", has_passed: true)
        end
      end

      before do
        create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
      end

      it "can be voided" do
        expect(participant_declaration.reload).to be_paid
        expect(participant_declaration.outcomes.count).to eql(1)

        travel_to declaration_date + 1.day do
          subject.call
        end
        expect(participant_declaration.reload).to be_awaiting_clawback
        expect(participant_declaration.outcomes.count).to eql(2)
        expect(participant_declaration.outcomes.latest).to be_voided
      end
    end
  end
end
