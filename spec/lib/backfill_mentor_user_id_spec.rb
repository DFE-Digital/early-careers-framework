# frozen_string_literal: true

require "rails_helper"
require "backfill_mentor_user_id"

describe BackfillMentorUserId, :with_default_schedules do
  let(:instance) { described_class.new(dry_run:) }
  let(:dry_run) { false }

  let(:mentor_profile) { create(:mentor_participant_profile) }
  let(:mentor_user_id) { mentor_profile.participant_identity.user_id }
  let(:participant_profile) { declaration.participant_profile }
  let(:declaration) { create(:ect_participant_declaration) }
  let(:logger) { instance_double(Logger, info: nil) }
  let(:latest_induction_record) { participant_profile.induction_records.latest }

  before do
    allow(Logger).to receive(:new) { logger }
    latest_induction_record.update!(mentor_profile:)
  end

  describe "#run" do
    subject(:run) { instance.run }

    it "updates the mentor_user_id on declarations" do
      run

      expect(logger).to have_received(:info).with("Backfilling 1 declarations")
      expect(declaration.reload).to have_attributes(mentor_user_id:)
      expect(logger).to have_received(:info).with("Finished backfilling declarations")
    end

    it "throttles the backfill process" do
      instance.stub(:sleep)
      run
      expect(instance).to have_received(:sleep).with(0.0025)
    end

    context "when declarations already have a mentor_user_id" do
      before { declaration.update!(mentor_user_id:) }

      it "does not change the declarations" do
        expect { run }.not_to change { declaration.mentor_user_id }

        expect(logger).to have_received(:info).with("Backfilling 0 declarations")
        expect(logger).to have_received(:info).with("Finished backfilling declarations")
      end
    end

    context "when the mentor was assigned after the declaration_date" do
      let(:declaration_date) { declaration.declaration_date }

      before { latest_induction_record.update!(start_date: declaration_date + 1.month) }

      it "does not change the declarations" do
        expect { run }.not_to change { declaration.mentor_user_id }

        expect(logger).to have_received(:info).with("Backfilling 1 declarations")
        expect(logger).to have_received(:info).with("Finished backfilling declarations")
      end
    end

    context "when there are more than 10 declarations" do
      before do
        create_list(:ect_participant_declaration, 10)
      end

      it "logs progress after every 10 declarations processed" do
        run

        expect(logger).to have_received(:info).with("Backfilling 11 declarations")
        expect(logger).to have_received(:info).with("10/11")
        expect(logger).to have_received(:info).with("Finished backfilling declarations")
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not update the mentor_user_id on declarations" do
        expect { run }.not_to change { declaration.mentor_user_id }

        expect(logger).to have_received(:info).with("~~DRY RUN~~")
        expect(logger).to have_received(:info).with("Backfilling 1 declarations")
        expect(logger).to have_received(:info).with("Finished backfilling declarations")
      end
    end
  end
end
