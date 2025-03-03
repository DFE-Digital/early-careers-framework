# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoidParticipantDeclaration do
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider) }
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
    let(:voided_by_user) { nil }
    let(:participant_declaration) do
      create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
    end

    subject do
      described_class.new(participant_declaration, voided_by_user:)
    end

    it "voids a participant declaration" do
      subject.call
      expect(participant_declaration.reload).to be_voided
    end

    context "when the voided_by_user is nil" do
      it "does not mark as voided by a user" do
        subject.call
        expect(participant_declaration.reload).to have_attributes({ voided_by_user: nil, voided_at: nil })
      end
    end

    context "when the voided_by_user is specified" do
      let(:voided_by_user) { create(:user) }

      it "marks the declaration as voided by the user" do
        subject.call
        expect(participant_declaration.reload).to have_attributes({ voided_by_user:, voided_at: be_within(5.seconds).of(Time.zone.now) })
      end
    end

    it "does not void a voided declaration" do
      subject.call

      expect {
        subject.call
      }.to raise_error Api::Errors::InvalidTransitionError
    end

    describe "mentor completion" do
      let(:mock_service) { instance_double(ParticipantDeclarations::HandleMentorCompletion) }

      before do
        allow(ParticipantDeclarations::HandleMentorCompletion).to receive(:new).with(participant_declaration:).and_return(mock_service)
      end

      it "calls the ParticipantDeclarations::HandleMentorCompletion service" do
        expect(mock_service).to receive(:call)
        subject.call
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
      let(:mock_service) { instance_double(Finance::ClawbackDeclaration, call: nil, errors: []) }

      before { allow(Finance::ClawbackDeclaration).to receive(:new).with(participant_declaration, voided_by_user:) { mock_service } }

      it "delegates to Finance::ClawbackDeclaration" do
        subject.call
        expect(mock_service).to have_received(:call)
      end

      context "when the voided_by_user is specified" do
        let(:voided_by_user) { create(:user) }

        it "forwards the user on to the clawback service" do
          subject.call
          expect(mock_service).to have_received(:call)
        end
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
      let(:line_item) { participant_declaration.statement_line_items.first }

      context "when declaration is eligible" do
        let(:participant_declaration) do
          create(
            :ect_participant_declaration,
            :eligible,
            cpd_lead_provider:,
            participant_profile:,
          )
        end

        it "updates declaration and line item state to voided" do
          subject.call
          expect(participant_declaration.reload).to be_voided
          expect(line_item.reload).to be_voided
        end
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

        it "updates declaration and line item state to voided" do
          subject.call
          expect(participant_declaration.reload).to be_voided
          expect(line_item.reload).to be_voided
        end
      end

      context "when declaration is ineligible" do
        let(:participant_declaration) do
          create(
            :ect_participant_declaration,
            :ineligible,
            cpd_lead_provider:,
            participant_profile:,
          )
        end

        before { line_item.ineligible! }

        it "updates declaration and line item state to voided" do
          subject.call
          expect(participant_declaration.reload).to be_voided
          expect(line_item.reload).to be_voided
        end
      end
    end
  end
end
