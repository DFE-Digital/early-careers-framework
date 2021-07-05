# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProfileDeclaration, type: :model do
  describe "scopes" do
    let(:call_off_contract) { create(:call_off_contract) }

    describe "ect_profiles" do
      let!(:ect_declaration) do
        create(:participant_declaration,
               :with_profile_type,
               lead_provider: call_off_contract.lead_provider)
      end

      it "includes declaration with ect profile" do
        expect(ProfileDeclaration.ect_profiles).to include(ect_declaration.profile_declaration)
      end
    end

    describe "mentor_profiles" do
      let!(:mentor_declaration) do
        create(:participant_declaration,
               :with_profile_type,
               lead_provider: call_off_contract.lead_provider,
               profile_type: :mentor_profile)
      end

      it "includes declaration with mentor profile" do
        expect(ProfileDeclaration.mentor_profiles).to include(mentor_declaration.profile_declaration)
      end
    end
  end
end
