# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  subject { described_class.new(user: create(:user)) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to have_many(:declaration_states) }
  end

  describe "state transitions" do
    context "when submitted" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }

      it "has an initial state of submitted" do
        expect(participant_declaration).to be_submitted
      end

      it "will move from submitted to eligible" do
        expect(participant_declaration.make_eligible!).to be_truthy
        expect(participant_declaration).to be_eligible
      end

      it "can be voided" do
        expect(participant_declaration.make_voided!).to be_truthy
        expect(participant_declaration).to be_voided
      end

      it "cannot be directly be made payable or paid" do
        expect(participant_declaration.make_paid!).to be_falsey
        expect(participant_declaration.make_payable!).to be_falsey
      end
    end

    context "when eligible" do
      let(:participant_declaration) { create(:ect_participant_declaration, :eligible) }

      it "has an state of eligible" do
        expect(participant_declaration).to be_eligible
      end

      it "can be voided" do
        expect(participant_declaration.make_voided!).to be_truthy
        expect(participant_declaration).to be_voided
      end

      it "can move from eligible to payable" do
        expect(participant_declaration.make_payable!).to be_truthy
        expect(participant_declaration).to be_payable
      end

      it "cannot be directly be made paid" do
        expect(participant_declaration.make_paid!).to be_falsey
      end
    end

    context "when payable" do
      let(:participant_declaration) { create(:ect_participant_declaration, :payable) }

      it "has an state of payable" do
        expect(participant_declaration).to be_payable
      end

      it "will not move to eligible or submitted" do
        expect(participant_declaration.make_submitted!).to be_falsey
        expect(participant_declaration.make_eligible!).to be_falsey
      end

      it "cannot be voided" do
        expect(participant_declaration.make_voided!).to be_falsey
      end

      it "can move from payable to paid" do
        expect(participant_declaration.make_paid!).to be_truthy
        expect(participant_declaration.paid?).to be_truthy
      end
    end

    context "when paid" do
      let(:participant_declaration) { create(:ect_participant_declaration, :paid) }

      it "has an state of paid" do
        expect(participant_declaration).to be_paid
      end

      it "will not move to eligible, payable or submitted" do
        expect(participant_declaration.make_submitted!).to be_falsey
        expect(participant_declaration.make_eligible!).to be_falsey
        expect(participant_declaration.make_payable!).to be_falsey
      end

      it "cannot be voided" do # TODO: This should trigger clawbacks, but that's a later thing.
        expect(participant_declaration.make_voided!).to be_falsey
      end
    end
  end

  describe "uplift scope" do
    let(:call_off_contract) { create(:call_off_contract) }

    context "when one profile" do
      context "for mentor was created" do
        let(:mentor_participant_declaration) do
          create(:mentor_participant_declaration,
                 :sparsity_uplift,
                 cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        end

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(mentor_participant_declaration)
        end
      end

      context "for early career teacher was created" do
        let(:ect_participant_declaration) do
          create(:ect_participant_declaration,
                 :sparsity_uplift,
                 cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        end

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(ect_participant_declaration)
        end
      end
    end
  end

  describe "declaration state" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }

    it "mirrors the most recent declaration_state" do
      participant_declaration.make_eligible!

      expect(participant_declaration.declaration_states.order(created_at: :desc).first).to be_eligible
      expect(participant_declaration).to be_eligible
    end
  end

  describe "voided!" do
    let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile: participant_declaration.participant_profile) }

    context "when declaration was payable" do
      before do
        participant_declaration.make_eligible!
      end

      it "voids the declaration" do
        expect(participant_declaration).to be_eligible
        participant_declaration.make_voided!
        expect(participant_declaration.eligible?).to be_falsey
        expect(participant_declaration.voided?).to be_truthy
      end
    end

    context "when declaration was not eligible" do
      before do
        eligibility.manual_check_status!
      end

      it "voids the declaration and keeps it not-eligible" do
        participant_declaration.voided!
        expect(participant_declaration.eligible?).to be_falsy
        expect(participant_declaration.voided?).to be_truthy
      end
    end
  end
end
