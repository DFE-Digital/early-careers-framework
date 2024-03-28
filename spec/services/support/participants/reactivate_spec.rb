# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Participants::Reactivate do
  subject(:reactivate) { described_class.new(participant_profile_id: participant_profile.id) }

  let(:school_cohort) { create(:school_cohort, :fip) }
  let(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
  let(:programme) { create(:induction_programme, :fip, school_cohort:, partnership:) }
  let(:participant_profile) { create(:ect_participant_profile, :ecf_participant_eligibility, school_cohort:) }

  before do
    Induction::Enrol.call(participant_profile:, induction_programme: programme)
    participant_profile.update!(status: :withdrawn, training_status: :withdrawn)
    participant_profile.latest_induction_record.withdrawing!
    Induction::ChangeInductionRecord.call(induction_record: participant_profile.latest_induction_record, changes: { training_status: "withdrawn" })

    # disable logging
    reactivate.logger = Logger.new("/dev/null")
  end

  describe "#call" do
    it "reactivates the participant" do
      expect { reactivate.call }.to change {
        [
          participant_profile.reload.status,
          participant_profile.reload.training_status,
          participant_profile.reload.latest_induction_record.induction_status,
          participant_profile.reload.latest_induction_record.training_status,
        ]
      }.from(%w[withdrawn withdrawn withdrawn withdrawn])
       .to(%w[active active active active])
    end

    describe "failures to update participant profile" do
      before do
        allow_any_instance_of(ParticipantProfile).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "rolls back the transaction" do
        expect { reactivate.call }.not_to change {
          [
            participant_profile.reload.status,
            participant_profile.reload.training_status,
            participant_profile.reload.latest_induction_record.induction_status,
            participant_profile.reload.latest_induction_record.training_status,
          ]
        }
      end
    end

    describe "validation failures" do
      before do
        allow_any_instance_of(Finance::ECF::ChangeTrainingStatusForm).to receive(:valid?).and_return(false)
      end

      it "rolls back the transaction" do
        expect { reactivate.call }.not_to change {
          [
            participant_profile.reload.status,
            participant_profile.reload.training_status,
            participant_profile.reload.latest_induction_record.induction_status,
            participant_profile.reload.latest_induction_record.training_status,
          ]
        }
      end
    end
  end
end
