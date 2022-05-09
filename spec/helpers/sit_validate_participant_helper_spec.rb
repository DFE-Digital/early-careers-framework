# frozen_string_literal: true

require "rails_helper"

RSpec.describe SitValidateParticipantHelper, type: :helper do
  let(:school_cohort) { create(:school_cohort) }
  let!(:ect_profile) { create(:ect_participant_profile, :ecf_participant_eligibility) }
  let!(:mentor_profile) { create(:mentor_participant_profile, :secondary_profile, :ecf_participant_eligibility) }

  describe "#ineligible?" do
    it "returns true when ineligible" do
      ect_profile.ecf_participant_eligibility.ineligible_status!
      expect(helper.ineligible?(ect_profile)).to be true
    end
  end

  describe "#eligible?" do
    it "returns true when eligible" do
      ect_profile.ecf_participant_eligibility.eligible_status!
      expect(helper.eligible?(ect_profile)).to be true
    end
  end

  describe "#ineligible_mentor_at_additional_school?" do
    it "returns true when the mentor has a profile alreayd at another school" do
      mentor_profile.ecf_participant_eligibility.ineligible_status!
      expect(helper.ineligible_mentor_at_additional_school?(mentor_profile)).to be true
    end
  end

  describe "#mentor_was_in_early_rollout?" do
    it "returns true when was in early roll out" do
      mentor_profile.ecf_participant_eligibility.previous_participation_reason!
      expect(helper.mentor_was_in_early_rollout?(mentor_profile)).to be true
    end

    it "returns early when an ect" do
      ect_profile.ecf_participant_eligibility.previous_participation_reason!
      expect(helper.mentor_was_in_early_rollout?(ect_profile)).to be nil
    end
  end

  describe "#exempt_from_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.exempt_from_induction_reason!
      expect(helper.exempt_from_induction?(ect_profile)).to be true
    end
  end

  describe "#previous_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.previous_induction_reason!
      expect(helper.previous_induction?(ect_profile)).to be true
    end
  end

  describe "#previous_induction?" do
    it "returns true exempt from induction" do
      ect_profile.ecf_participant_eligibility.no_qts_reason!
      expect(helper.participant_has_no_qts?(ect_profile)).to be true
    end
  end
end
