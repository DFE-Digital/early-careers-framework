# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  subject { described_class.new(user: create(:user)) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to have_one(:participant_profile).through(:profile_declaration) }
    it { is_expected.to have_one(:current_state) }
    it { is_expected.to have_many(:declaration_states) }
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

    it "returns the current state" do
      state_new = create(:declaration_state, :payable, participant_declaration: participant_declaration)

      expect(participant_declaration.current_state).to eq(state_new)
    end
  end

  describe "refresh_payability!" do
    let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_declaration.participant_profile_id) }

    context "when declaration was payable" do
      before do
        eligibility.eligible_status!
        participant_declaration.refresh_payability!
      end

      context "when declaration becomes non-payable" do
        before do
          eligibility.manual_check_status!
        end

        it "makes the declaration submitted if currently payable" do
          expect(participant_declaration.payable?).to be_truthy
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.declaration_states.count }.by(1)
          expect(participant_declaration.payable?).to be_falsey
          expect(participant_declaration.submitted?).to be_truthy
        end

        it "keeps the declaration voided if it was voided already" do
          participant_declaration.void!
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.voided?).to be_truthy
        end
      end

      context "when declaration remains payable" do
        it "does not create a new declaration state" do
          expect(participant_declaration.payable?).to be_truthy
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.payable?).to be_truthy
        end
      end
    end

    context "when declaration was not payable" do
      before do
        eligibility.manual_check_status!
      end

      context "when declaration becomes payable" do
        before do
          eligibility.eligible_status!
        end

        it "creates a new declaration state which is payable" do
          expect(participant_declaration.submitted?).to be_truthy
          eligibility.eligible_status!
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.declaration_states.count }.by(1)
          expect(participant_declaration.payable?).to be_truthy
        end

        it "keeps the declaration voided if it was voided already" do
          participant_declaration.void!
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.voided?).to be_truthy
        end
      end

      context "when declaration remains non-payable" do
        it "does not create a new declaration state" do
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.payable?).to be_falsey
        end
      end
    end
  end

  describe "void!" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_declaration.participant_profile_id) }

    context "when declaration was payable" do
      before do
        eligibility.eligible_status!
      end

      it "voids the declaration" do
        participant_declaration.void!
        expect(participant_declaration.payable?).to be_falsey
        expect(participant_declaration.voided?).to be_truthy
      end
    end

    context "when declaration was not payable" do
      before do
        eligibility.manual_check_status!
      end

      it "voids the declaration and keeps it non-payable" do
        participant_declaration.void!
        expect(participant_declaration.payable?).to be_falsy
        expect(participant_declaration.voided?).to be_truthy
      end
    end
  end
end
