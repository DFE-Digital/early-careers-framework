# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECFUserSerializer, :with_support_for_ect_examples do
  it "includes the correct id" do
    expect(record_id(cip_ect_only)).to eq cip_ect_only.user.id
  end

  it "includes the correct full_name" do
    expect(record_attributes(cip_ect_only)[:full_name]).to eq cip_ect_only.user.full_name
  end

  it "includes the correct email" do
    expect(record_attributes(cip_ect_only)[:email]).to eq cip_ect_only.user.email
  end

  describe "registration_completed" do
    context "before validation started" do
      it "returns false" do
        expect(record_attributes(cip_ect_only)[:registration_completed]).to be false
      end
    end

    context "when details were not matched" do
      before do
        create(:ecf_participant_validation_data, participant_profile: cip_ect_only)
      end

      it "returns true" do
        expect(record_attributes(cip_ect_only)[:registration_completed]).to be true
      end
    end

    context "when the details were matched" do
      it "returns true" do
        expect(record_attributes(cip_ect_reg_complete)[:registration_completed]).to be true
      end
    end
  end

private

  def record_attributes(profile)
    described_class.new(profile.user).serializable_hash[:data][:attributes]
  end

  def record_id(profile)
    described_class.new(profile.user).serializable_hash[:data][:id]
  end
end
