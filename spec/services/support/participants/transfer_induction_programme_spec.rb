# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Participants::TransferInductionProgramme do
  subject(:reactivate) { described_class.new(participant_profile_id:, induction_programme_id:) }

  let(:school_cohort) { create(:school_cohort, :fip) }
  let(:partnership) { create :partnership, school: school_cohort.school, cohort: school_cohort.cohort }
  let(:programme) { create(:induction_programme, :fip, school_cohort:, partnership:) }
  let(:new_programme) { create(:induction_programme, :fip, school_cohort:, partnership:) }
  let(:participant_profile) { create(:ect_participant_profile, :ecf_participant_eligibility, school_cohort:) }

  let(:participant_profile_id) { participant_profile.id }
  let(:induction_programme_id) { new_programme.id }

  before do
    Induction::Enrol.call(participant_profile:, induction_programme: programme)

    # disable logging
    reactivate.logger = Logger.new("/dev/null")
  end

  describe "#call" do
    it "moves the induction programme" do
      expect { reactivate.call }.to change {
        participant_profile.reload.latest_induction_record.induction_programme
      }.from(programme)
       .to(new_programme)
    end

    describe "failures to update participant profile" do
      describe "update raises an error" do
        before do
          allow_any_instance_of(InductionRecord).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
          allow_any_instance_of(InductionRecord).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        it "rolls back the transaction" do
          expect { reactivate.call }.to_not change { participant_profile.reload.latest_induction_record.induction_programme }
        end
      end

      describe "the induciton programme is not for the same school as the participant profile" do
        let(:other_school_cohort) { create(:school_cohort, :fip) }
        let(:new_programme) { create(:induction_programme, :fip, school_cohort: other_school_cohort, partnership:) }

        it "rolls back the transaction" do
          expect { reactivate.call }.to_not change { participant_profile.reload.latest_induction_record.induction_programme }
        end
      end
    end
  end
end
