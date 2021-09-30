# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFUserSerializer do
  let(:ect_profile) { create(:participant_profile, :ect) }

  describe "registration_completed" do
    context "before validation started" do
      it "returns false" do
        expect(user_attributes(ect_profile.user)[:registration_completed]).to be false
      end
    end

    context "when details were not matched" do
      before do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)
      end

      it "returns true" do
        expect(user_attributes(ect_profile.user)[:registration_completed]).to be true
      end
    end

    context "when the details were matched" do
      before do
        create(:ecf_participant_validation_data, participant_profile: ect_profile)
        eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
        eligibility.matched_status!
      end

      it "returns true" do
        expect(user_attributes(ect_profile.user)[:registration_completed]).to be true
      end
    end
  end

private

  def user_attributes(user)
    described_class.new(user).serializable_hash[:data][:attributes]
  end
end
