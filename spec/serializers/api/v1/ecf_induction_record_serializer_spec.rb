# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECFInductionRecordSerializer, :with_support_for_ect_examples do
  it "includes the correct id" do
    expect(record_id(cip_ect_only)).to eq cip_ect_only.user.id
  end

  it "includes the correct full_name" do
    expect(record_attributes(cip_ect_only)[:full_name]).to eq cip_ect_only.user.full_name
  end

  it "includes the correct email" do
    expect(record_attributes(cip_ect_only)[:email]).to eq cip_ect_only.participant_identity.email
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

  describe "when an induction_record has a missing preferred_identity" do
    let!(:participant_with_missing_identity) do
      school_cohort = create(:school_cohort)
      induction_programme = create(:induction_programme, :fip, school_cohort:)
      user = create(:user, email: "ect@example.com")
      preferred_identity_ect = create(:participant_identity, user:)
      preferred_identity_mentor = create(:participant_identity, :secondary, user:, email: "mentor@example.com")
      teacher_profile = create(:teacher_profile, user:)
      ect_profile = create(:ect_participant_profile, teacher_profile:, participant_identity: preferred_identity_ect)
      Induction::Enrol.call(participant_profile: ect_profile, induction_programme:, start_date: 1.year.ago)
      mentor_profile = create(:mentor_participant_profile, teacher_profile:, participant_identity: preferred_identity_mentor)
      Induction::Enrol.call(participant_profile: mentor_profile, induction_programme:, start_date: 6.months.ago)
      mentor_profile.induction_records.first.update! preferred_identity_id: preferred_identity_mentor.id
      preferred_identity_mentor.delete

      mentor_profile
    end

    it "includes an email address" do
      expect(record_attributes(participant_with_missing_identity)[:email]).to eq participant_with_missing_identity.participant_identity.email
    end

    it "includes a full name" do
      expect(record_attributes(participant_with_missing_identity)[:full_name]).to eq participant_with_missing_identity.participant_identity.user.full_name
    end
  end

private

  def record_attributes(profile)
    described_class.new(profile.current_induction_records.first).serializable_hash[:data][:attributes]
  end

  def record_id(profile)
    described_class.new(profile.current_induction_records.first).serializable_hash[:data][:id]
  end
end
