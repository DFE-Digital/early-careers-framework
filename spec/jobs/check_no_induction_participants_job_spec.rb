# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckNoInductionParticipantsJob do
  let(:dqt_records) { [dqt_record] }
  let(:validation_result) do
    lambda do |trn, no_induction|
      {
        trn: trn,
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
        no_induction: no_induction,
      }
    end
  end

  before do
    still_no_induction_trn = still_no_induction_participant.ecf_participant_validation_data.trn
    expect(ParticipantValidationService).to(
      receive(:validate).with(
        hash_including(
          trn: still_no_induction_trn,
        ),
      ).and_return(
        validation_result[still_no_induction_trn, true],
      ),
    )

    added_induction_trn = added_induction_participant.ecf_participant_validation_data.trn
    expect(ParticipantValidationService).to(
      receive(:validate).with(
        hash_including(
          trn: added_induction_trn,
        ),
      ).and_return(
        validation_result[added_induction_trn, false],
      ),
    )
  end

  context "When there are participants that have had their induction information filled" do
    let!(:still_no_induction_participant) do
      create(:ecf_participant_profile).tap do |profile|
        create(
          :ecf_participant_eligibility,
          :manual_check,
          no_induction: true,
          participant_profile: profile,
        )
        create(
          :ecf_participant_validation_data,
          trn: profile.teacher_profile.trn,
          participant_profile: profile,
        )
      end
    end

    let!(:added_induction_participant) do
      create(:ecf_participant_profile).tap do |profile|
        create(
          :ecf_participant_eligibility,
          :manual_check,
          no_induction: true,
          participant_profile: profile,
        )
        create(
          :ecf_participant_validation_data,
          trn: profile.teacher_profile.trn,
          participant_profile: profile,
        )
      end
    end

    it "Updates the value of no_induction for " do
      expect {
        subject.perform_now
      }.to change {
        added_induction_participant.ecf_participant_eligibility.reload.no_induction
      }.from(true).to(false).and not_change {
        still_no_induction_participant.ecf_participant_eligibility.reload.no_induction
      }
      expect(added_induction_participant.ecf_participant_eligibility).to be_eligible_status
    end
  end
end
