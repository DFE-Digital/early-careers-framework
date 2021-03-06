# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to have_one(:profile_declaration) }
  end

  describe "uplift scope" do
    let(:call_off_contract) { create(:call_off_contract) }

    context "when one profile" do
      let(:profile_declaration) do
        create(:participant_declaration,
               :with_profile_type,
               lead_provider: call_off_contract.lead_provider,
               profile_type: profile_type)
      end

      context "for mentor was created" do
        let(:profile_type) { :mentor_profile }

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(profile_declaration)
        end
      end

      context "for early career teacher was created" do
        let(:profile_type) { :early_career_teacher_profile }

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(profile_declaration)
        end
      end
    end
  end
end
