# frozen_string_literal: true

require "rails_helper"

RSpec.describe SitValidateParticipantHelper, type: :helper do
  let!(:ect_profile)    { create(:ect, :eligible_for_funding) }
  let!(:mentor_profile) { create(:mentor, :eligible_for_funding) }
  let(:user) { create(:user) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile, user:) }
  let(:form) { Schools::AddParticipantForm.new(current_user_id: user.id) }

  describe "#ineligible?" do
    it "returns true when ineligible" do
      ect_profile.ecf_participant_eligibility.ineligible_status!
      expect(helper).to be_ineligible(ect_profile)
    end
  end

  describe "#eligible?" do
    it "returns true when eligible" do
      ect_profile.ecf_participant_eligibility.eligible_status!
      expect(helper).to be_eligible(ect_profile)
    end
  end

  describe "#ineligible_mentor_at_additional_school?" do
    before do
      mentor_profile.ecf_participant_eligibility.ineligible_status!
      mentor_profile.ecf_participant_eligibility.duplicate_profile_reason!
    end

    it "returns true when the mentor has a profile alreayd at another school" do
      expect(helper).to be_ineligible_mentor_at_additional_school(mentor_profile)
    end
  end

  describe "#mentor_was_in_early_rollout?" do
    it "returns true when was in early roll out" do
      mentor_profile.ecf_participant_eligibility.previous_participation_reason!
      expect(helper).to be_mentor_was_in_early_rollout(mentor_profile)
    end

    it "returns early when an ect" do
      ect_profile.ecf_participant_eligibility.previous_participation_reason!
      expect(helper).not_to be_mentor_was_in_early_rollout(ect_profile)
    end
  end

  describe "#exempt_from_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.exempt_from_induction_reason!
      expect(helper).to be_exempt_from_induction(ect_profile)
    end
  end

  describe "#previous_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.previous_induction_reason!
      expect(helper).to be_previous_induction(ect_profile)
    end
  end

  describe "#previous_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.no_qts_reason!
      expect(helper).to be_participant_has_no_qts(ect_profile)
    end
  end
end
