# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  subject { described_class.new(user: create(:user)) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to have_one(:participant_profile).through(:profile_declaration) }
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
      participant_declaration.make_eligible!

      expect(participant_declaration.declaration_states.order(created_at: :desc).first.state).to eq("eligible")
      expect(participant_declaration.eligible?).to be_truthy
    end
  end

  describe "refresh_payability!" do
    let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile: participant_declaration.participant_profile) }

    context "when declaration was eligible for payment" do
      before do
        eligibility.eligible_status!
        participant_declaration.refresh_payability!
      end

      context "when declaration becomes not eligible for payment" do
        it "makes the declaration submitted if currently eligible for payment" do
          expect(participant_declaration.eligible?).to be_truthy
          eligibility.manual_check_status!
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.declaration_states.count }.by(1)
          expect(participant_declaration.eligible?).to be_falsey
          expect(participant_declaration.submitted?).to be_truthy
        end

        it "keeps the declaration voided if it was voided already" do
          participant_declaration.voided!
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.voided?).to be_truthy
        end
      end

      context "when declaration remains eligible" do
        it "does not create a new declaration state" do
          expect(participant_declaration.eligible?).to be_truthy
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.eligible?).to be_truthy
        end
      end
    end

    context "when declaration was not eligible for payment" do
      before do
        eligibility.manual_check_status!
      end

      context "when participant becomes eligible" do
        before do
          eligibility.eligible_status!
        end

        it "creates a new declaration state which is also eligible" do
          expect(participant_declaration.submitted?).to be_truthy
          eligibility.eligible_status!
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.declaration_states.count }.by(1)
          expect(participant_declaration.eligible?).to be_truthy
        end

        it "keeps the declaration voided if it was voided already" do
          participant_declaration.voided!
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.voided?).to be_truthy
        end
      end

      context "when declaration remains non-payable" do
        it "does not create a new declaration state" do
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.declaration_states.count }
          expect(participant_declaration.eligible?).to be_falsey
        end
      end
    end
  end

  describe "voided!" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile: participant_declaration.participant_profile) }

    context "when declaration was payable" do
      before do
        eligibility.eligible_status!
      end

      it "voids the declaration" do
        participant_declaration.voided!
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
