# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckEligibleEctsThatFailedPermanentCohortSetupJob do
  let(:eligible_ect) { create(:ecf_participant_eligibility, status: :eligible).participant_profile }
  let(:non_eligible_ect) { error_for_non_eligible_ect.participant_profile }
  let!(:error_for_eligible_ect) { create(:sync_dqt_induction_start_date_error, participant_profile: eligible_ect) }
  let!(:error_for_non_eligible_ect) { create(:sync_dqt_induction_start_date_error) }

  before do
    allow(Participants::SyncDQTInductionStartDate).to receive(:call)
    subject.perform_now
  end

  it "process errors about eligible participants" do
    expect(Participants::SyncDQTInductionStartDate)
      .to have_received(:call).with(eligible_ect.induction_start_date, eligible_ect)
  end

  it "do not process errors about non-eligible participants" do
    expect(Participants::SyncDQTInductionStartDate)
      .not_to have_received(:call).with(non_eligible_ect.induction_start_date, non_eligible_ect)
  end
end
