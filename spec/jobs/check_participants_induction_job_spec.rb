# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckParticipantsInductionJob do
  context "When there are participants that have had their induction information filled" do
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

    let(:still_no_induction_participant) do
      create(:ect_participant_profile).tap do |profile|
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

    let(:added_induction_participant) do
      create(:ect_participant_profile).tap do |profile|
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

    it "Updates the value of no_induction from dqt" do
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

  context "When there are participants who have previous_induction" do
    let(:validation_result) do
      lambda do |trn, previous_induction|
        {
          trn: trn,
          qts: true,
          active_alert: false,
          previous_participation: false,
          previous_induction: previous_induction,
          no_induction: false,
        }
      end
    end

    let(:still_previous_induction_participant) do
      create(:ect_participant_profile).tap do |profile|
        create(
          :ecf_participant_eligibility,
          :ineligible,
          previous_induction: true,
          participant_profile: profile,
        )
        create(
          :ecf_participant_validation_data,
          trn: profile.teacher_profile.trn,
          participant_profile: profile,
        )
      end
    end

    let(:new_later_induction_participant) do
      create(:ect_participant_profile).tap do |profile|
        create(
          :ecf_participant_eligibility,
          :ineligible,
          previous_induction: true,
          participant_profile: profile,
        )
        create(
          :ecf_participant_validation_data,
          trn: profile.teacher_profile.trn,
          participant_profile: profile,
        )
      end
    end

    before do
      still_previous_induction_trn = still_previous_induction_participant.ecf_participant_validation_data.trn
      expect(ParticipantValidationService).to(
        receive(:validate).with(
          hash_including(
            trn: still_previous_induction_trn,
          ),
        ).and_return(
          validation_result[still_previous_induction_trn, true],
        ),
      )

      new_later_induction_trn = new_later_induction_participant.ecf_participant_validation_data.trn
      expect(ParticipantValidationService).to(
        receive(:validate).with(
          hash_including(
            trn: new_later_induction_trn,
          ),
        ).and_return(
          validation_result[new_later_induction_trn, false],
        ),
      )
    end

    it "Updates the value of previous_induction from dqt" do
      expect {
        subject.perform_now
      }.to change {
        new_later_induction_participant.ecf_participant_eligibility.reload.previous_induction
      }.from(true).to(false).and not_change {
        still_previous_induction_participant.ecf_participant_eligibility.reload.no_induction
      }
      expect(new_later_induction_participant.ecf_participant_eligibility).to be_eligible_status
    end
  end
end
