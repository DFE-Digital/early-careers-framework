# frozen_string_literal: true

require "rails_helper"

RSpec.describe ManuallyUpdateParticipantEligibility do
  describe ".call" do
    subject(:service) { described_class }
    let(:school) { create(:school) }
    let(:school_cohort) { create(:school_cohort, school:) }
    let(:teacher_profile) { create(:teacher_profile, school:, trn: nil) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:, teacher_profile:) }
    let!(:participant_eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

    it "overrides the normal status determination" do
      service.call(participant_profile:, status: :eligible, reason: :none)
      expect(participant_eligibility.reload).to be_eligible_status
      expect(participant_eligibility).to be_none_reason
      expect(participant_eligibility).not_to be_qts
    end

    it "sets the manually_validated flag on the eligibility record" do
      service.call(participant_profile:, status: :eligible, reason: :none)
      expect(participant_eligibility.reload).to be_manually_validated
    end
  end
end
