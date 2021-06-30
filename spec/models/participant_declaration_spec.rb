# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  describe "uplift scope" do
    let(:call_off_contract) { create(:call_off_contract) }

    context "when one profile" do
      let(:profile_declaration) do
        create(:participant_declaration,
               :with_profile_type_declaration,
               lead_provider: call_off_contract.lead_provider,
               profile_type: profile_type)
      end

      context "for mentor was created" do
        let(:profile_type) { :mentor_profile_declaration }

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(profile_declaration)
        end
      end

      context "for eearly career teacher was created" do
        let(:profile_type) { :early_career_teacher_profile_declaration }

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(profile_declaration)
        end
      end
    end

    context "when both mentor and ect profiles were created" do
      let(:ect_declaration) do
        create(:participant_declaration,
               :with_profile_type_declaration,
               lead_provider: call_off_contract.lead_provider,
               profile_type: :early_career_teacher_profile_declaration)
      end

      let(:mentor_declaration) do
        create(:participant_declaration,
               :with_profile_type_declaration,
               lead_provider: call_off_contract.lead_provider,
               profile_type: :mentor_profile_declaration)
      end

      it "includes declaration with mentor profile" do
        expect(ParticipantDeclaration.uplift).to include(ect_declaration, mentor_declaration)
      end
    end
  end
end
