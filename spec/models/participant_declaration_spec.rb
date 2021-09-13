# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  subject { described_class.new(user: create(:user)) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to have_one(:participant_profile).through(:current_profile_declaration) }
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

  describe "current_profile_declaration" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }
    let!(:participant_profile) { create(:participant_profile, :ect) }

    it "returns latest profile declaration" do
      create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now - 1.day)
      declaration_new = create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now)

      expect(participant_declaration.current_profile_declaration).to eq(declaration_new)
    end
  end

  describe "refresh_payability!" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }
    let!(:participant_profile) { create(:participant_profile, :ect) }

    context "when declaration was payable" do
      let(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_profile.id) }

      before do
        eligibility.eligible_status!
        create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now, payable: true)
      end

      context "when declaration becomes non-payable" do
        before do
          eligibility.manual_check_status!
        end

        it "creates a new profile declaration which is non-payable" do
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.profile_declarations.count }.by(1)
          expect(participant_declaration.payable).to be_falsey
        end

        it "creates new profile declaration which is voided if it is already voided" do
          participant_declaration.void!
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.profile_declarations.count }.by(1)
          expect(participant_declaration.voided).to be_truthy
        end
      end

      context "when declaration remains payable" do
        it "does not create a new profile declaration" do
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.profile_declarations.count }
          expect(participant_declaration.payable).to be_truthy
        end
      end
    end

    context "when declaration was not payable" do
      let(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_profile.id) }

      before do
        eligibility.manual_check_status!
        create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now, payable: false)
      end

      context "when declaration becomes payable" do
        before do
          eligibility.eligible_status!
        end

        it "creates a new profile declaration which is payable" do
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.profile_declarations.count }.by(1)
          expect(participant_declaration.payable).to be_truthy
        end

        it "creates new profile declaration which is voided if it is already voided" do
          participant_declaration.void!
          expect { participant_declaration.refresh_payability! }.to change { participant_declaration.profile_declarations.count }.by(1)
          expect(participant_declaration.voided).to be_truthy
        end
      end

      context "when declaration remains non-payable" do
        it "does not create a new profile declaration" do
          expect { participant_declaration.refresh_payability! }.not_to change { participant_declaration.profile_declarations.count }
          expect(participant_declaration.payable).to be_falsey
        end
      end
    end
  end

  describe "void!" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }
    let!(:participant_profile) { create(:participant_profile, :ect) }

    context "when declaration was payable" do
      let(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_profile.id) }

      before do
        eligibility.eligible_status!
        create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now, payable: true)
      end

      it "voids the declaration and keeps it payable" do
        participant_declaration.void!
        expect(participant_declaration.payable).to be_truthy
        expect(participant_declaration.voided).to be_truthy
      end
    end

    context "when declaration was not payable" do
      let(:eligibility) { ECFParticipantEligibility.create!(participant_profile_id: participant_profile.id) }

      before do
        eligibility.manual_check_status!
        create(:profile_declaration, participant_declaration: participant_declaration, participant_profile: participant_profile, created_at: Time.zone.now, payable: false)
      end

      it "voids the declaration and keeps it non-payable" do
        participant_declaration.void!
        expect(participant_declaration.payable).to be_falsy
        expect(participant_declaration.voided).to be_truthy
      end
    end
  end
end
