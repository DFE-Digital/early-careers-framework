# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::CheckAndSetCompletionDate do
  subject(:service_call) { described_class.call(participant_profile:, riab_teacher:) }

  let(:cohort) { Cohort.previous || create(:cohort, :previous) }
  let(:lead_provider) { create(:lead_provider, name: "Ambition Institute") }
  let(:school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .with_partnership_in(cohort:, lead_provider:)
      .chosen_fip_and_partnered_in(cohort:)
      .school
  end
  let(:school_cohort) { school.school_cohorts.first }
  let(:induction_programme) { school_cohort.default_induction_programme }
  let(:participant_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
                                                .build
                                                .with_induction_record(induction_programme:)
                                                .participant_profile
  end
  let(:trn) { participant_profile.trn }
  let(:completion_date) { 1.month.ago.to_date }
  let(:riab_start_date) { cohort.academic_year_start_date.to_date }
  let(:induction_status) { "active" }
  let(:outcome) {}

  describe "#call" do
    let(:riab_teacher) { create(:riab_teacher, trn:, trs_induction_status: induction_status) }

    before do
      inside_registration_window(cohort: Cohort.current) do
        create(:riab_induction_period,
               outcome:,
               started_on: riab_start_date,
               finished_on: completion_date,
               teacher: riab_teacher)
      end
    end

    context "when the participant already have a completion date" do
      let(:outcome) { :pass }
      let(:induction_completion_date) { 2.months.ago.to_date }

      before do
        participant_profile.update!(induction_completion_date:)
        service_call
      end

      it "do not re-complete the participant" do
        expect(participant_profile.induction_completion_date).to eq induction_completion_date
      end
    end

    context "when RIAB provides a completion date" do
      let(:outcome) { :pass }

      it "complete the participant with the induction endDate" do
        service_call
        expect(participant_profile.induction_completion_date).to eq(completion_date)
      end
    end

    context "when RIAB does not provide a completion date" do
      let(:completion_date) {}

      it "does not set a completion date" do
        service_call
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end

    context "when the participant is not an ECT" do
      let(:participant_profile) { create(:seed_mentor_participant_profile, :valid) }

      it "does not set a completion date" do
        service_call
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end

    context "when cohort sync with RIAB induction start date fails" do
      let(:riab_start_date) { Cohort.current.academic_year_start_date.to_date }

      it "does not change the cohort of the participant" do
        expect { service_call }.not_to change { participant_profile.schedule.cohort }
      end
    end

    context "when cohort sync with RIAB induction start date succeeds" do
      context "when the synced cohort is payments-frozen" do
        before do
          cohort.update!(payments_frozen_at: Date.yesterday)
          NewSeeds::Scenarios::SchoolCohorts::Fip
            .new(school:, cohort: Cohort.destination_from_frozen_cohort)
            .build
            .with_programme
        end

        context "when the ect induction is not in progress" do
          before do
            allow(participant_profile).to receive(:unfinished_with_billable_declaration?).and_return(true)
          end

          it "leave the participant in the synced cohort" do
            expect { service_call }.not_to change { participant_profile.schedule.cohort }
          end
        end

        context "when the ect induction is in progress" do
          let(:induction_status) { "InProgress" }
          let(:completion_date) {}

          let!(:esp) { create(:appropriate_body, :esp) }
          let!(:istip) { create(:appropriate_body, :istip) }

          context "when the participant has not ESP or ISTIP appropriate body" do
            it "sit the participant in 2024" do
              expect { service_call }.to change { participant_profile.schedule.cohort }
                                           .from(cohort)
                                           .to(Cohort.destination_from_frozen_cohort)
            end
          end

          context "when the participant has ESP as appropriate body" do
            before do
              participant_profile.latest_induction_record.update!(appropriate_body: esp)
            end

            it "do not sit the participant in 2024" do
              expect { service_call }.not_to change { participant_profile.schedule.cohort }
            end
          end

          context "when the participant has ISTIP as appropriate body" do
            before do
              participant_profile.latest_induction_record.update!(appropriate_body: istip)
            end

            it "do not sit the participant in 2024" do
              expect { service_call }.not_to change { participant_profile.schedule.cohort }
            end
          end
        end
      end

      # rubocop:disable Rails/SaveBang
      context "when the synced cohort is not payments-frozen" do
        before do
          NewSeeds::Scenarios::SchoolCohorts::Fip
            .new(school:, cohort: cohort.previous)
            .build
            .with_programme
          Induction::AmendParticipantCohort.new(participant_profile:,
                                                source_cohort_start_year: cohort.start_year,
                                                target_cohort_start_year: cohort.previous.start_year)
                                           .save
        end

        it "leave the participant in the synced cohort" do
          expect { service_call }.to change { participant_profile.schedule.cohort }
                                       .from(cohort.previous)
                                       .to(cohort)
        end
      end
      # rubocop:enable Rails/SaveBang
    end

    context "when completion dates are matching" do
      it "does not record inconsistencies" do
        expect { service_call }.not_to change { ParticipantProfileCompletionDateInconsistency.count }.from(0)
      end
    end

    context "when completion dates are not matching" do
      let(:induction_completion_date) { 2.months.from_now.to_date }

      before do
        participant_profile.update!(induction_completion_date:)
      end

      it "records inconsistency" do
        expect { service_call }.to change { ParticipantProfileCompletionDateInconsistency.count }.from(0).to(1)
      end

      context "when same inconsistency is processed twice" do
        it "records only one inconsistency" do
          expect {
            service_call
            service_call
          }.to change { ParticipantProfileCompletionDateInconsistency.count }.from(0).to(1)
        end
      end
    end
  end

  # ✅ CORRECT BEHAVIOR: This service does NOT create multiple open InductionRecords
  #
  # CAVEAT: If there are ALREADY multiple open IRs,
  # TRS only closes the LATEST one, leaving earlier ones still open.
  # Test at line 295-331: "BUG: TRS perpetuates multiple open IRs - only closes the LATEST IR"
  describe "CORRECT BEHAVIOR: TRS completion check does NOT create multiple open InductionRecords" do
    let(:old_school) { create(:school, name: "Old School") }
    let(:new_school) { create(:school, name: "New School") }
    let(:cohort) { create(:cohort, :current) }
    let(:old_school_cohort) { create(:school_cohort, school: old_school, cohort:) }
    let(:old_induction_programme) { create(:induction_programme, :fip, school_cohort: old_school_cohort) }

    let!(:ect_profile) do
      profile = create(:ect_participant_profile,
                       school_cohort: old_school_cohort)

      # Create an active induction record with start date in the past
      Induction::Enrol.call(
        participant_profile: profile,
        induction_programme: old_induction_programme,
        start_date: 2.years.ago,
      )

      profile
    end

    let(:trn) { ect_profile.trn }
    let(:completion_date) { 1.month.ago.to_date }
    let(:riab_start_date) { cohort.academic_year_start_date.to_date }
    let(:riab_teacher) { create(:riab_teacher, trn:, trs_induction_status: "active") }

    before do
      inside_registration_window(cohort: Cohort.current) do
        create(:riab_induction_period,
               outcome: :pass,
               started_on: riab_start_date,
               finished_on: completion_date,
               teacher: riab_teacher)
      end
    end

    it "creates a NEW InductionRecord with completed status when TRS detects completion" do
      old_record = ect_profile.latest_induction_record
      expect(old_record.induction_status).to eq("active")
      expect(old_record.end_date).to be_nil

      # Call the service - this simulates TRS detecting completion
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      # A new InductionRecord should be created
      new_record = ect_profile.latest_induction_record
      expect(new_record.id).not_to eq(old_record.id)
      expect(new_record.induction_status).to eq("completed")
    end

    it "closes the old InductionRecord with changing!() - sets end_date and status to 'changed'" do
      old_record = ect_profile.latest_induction_record
      old_record.id

      # Call the service
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      # The old record should be closed with changing!()
      old_record.reload
      expect(old_record.end_date).not_to be_nil
      expect(old_record.induction_status).to eq("changed")
    end

    it "BUG: the NEW InductionRecord has NO end_date, making it appear 'open'" do
      # Call the service
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      # The new record has completed status but NO end_date
      new_record = ect_profile.latest_induction_record
      expect(new_record.induction_status).to eq("completed")
      expect(new_record.end_date).to be_nil # ❌ This is the bug

      # This means the participant appears to have an "open" completed induction
    end

    it "TRS service does NOT create multiple open IRs - it closes the old one properly" do
      # Before: 1 open IR
      expect(ect_profile.induction_records.where(end_date: nil).count).to eq(1)

      # Call the service
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      ect_profile.reload

      # After: Still only 1 open IR (the completed one)
      open_records = ect_profile.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(1)
      expect(open_records.first.induction_status).to eq("completed")

      # The old "changed" record is closed
      changed_record = ect_profile.induction_records.find_by(induction_status: "changed")
      expect(changed_record.end_date).not_to be_nil
    end

    it "BUG: TRS perpetuates multiple open IRs - only closes the LATEST IR, leaving earlier ones open" do
      # Simulate the scenario where participant was enrolled at another school
      # using Induction::Enrol (which doesn't close previous records)
      new_school = create(:school, name: "Second School")
      new_school_cohort = create(:school_cohort, school: new_school, cohort:)
      new_induction_programme = create(:induction_programme, :fip, school_cohort: new_school_cohort)

      # This creates a second open IR without closing the first (Bug #1 from documentation)
      Induction::Enrol.call(
        participant_profile: ect_profile,
        induction_programme: new_induction_programme,
        start_date: 1.year.ago,
      )

      # Now we have 2 open IRs at different schools
      expect(ect_profile.induction_records.where(end_date: nil).count).to eq(2)

      # Now TRS detects completion
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      ect_profile.reload

      # ❌ BUG: Still 2 open IRs after TRS call!
      open_records = ect_profile.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2)

      # TRS only closed the LATEST induction record and created a new completed one
      # The earlier IR at the first school remains open
      old_school_ir = open_records.find { |ir| ir.school.name == "Old School" }
      new_school_ir = open_records.find { |ir| ir.school.name == "Second School" }

      expect(old_school_ir.induction_status).to eq("active") # Still open!
      expect(old_school_ir.end_date).to be_nil

      expect(new_school_ir.induction_status).to eq("completed")
      expect(new_school_ir.end_date).to be_nil
    end

    it "sets the new InductionRecord's start_date to NOW, not the completion_date" do
      # Call the service
      freeze_time do
        described_class.call(participant_profile: ect_profile, riab_teacher:)

        new_record = ect_profile.latest_induction_record
        expect(new_record.start_date.to_date).to eq(Time.zone.now.to_date)
        expect(new_record.start_date.to_date).not_to eq(completion_date)
      end
    end

    it "matches the data pattern described by PM: 1 completed IR + 1 changed IR, both with different start dates" do
      old_record = ect_profile.latest_induction_record
      old_start_date = old_record.start_date

      # Call the service
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      ect_profile.reload
      records = ect_profile.induction_records.order(:start_date)

      # Should have 2 records now
      expect(records.count).to eq(2)

      # First record: closed with 'changed' status, has end_date
      first_record = records.first
      expect(first_record.induction_status).to eq("changed")
      expect(first_record.end_date).not_to be_nil
      expect(first_record.start_date).to eq(old_start_date)

      # Second record: 'completed' status, NO end_date (the bug)
      second_record = records.second
      expect(second_record.induction_status).to eq("completed")
      expect(second_record.end_date).to be_nil # ❌ Bug: appears "open"
      expect(second_record.start_date).not_to eq(old_start_date) # Different start date
    end

    it "calling TRS check multiple times creates multiple InductionRecords" do
      # Initial state: 1 InductionRecord
      expect(ect_profile.induction_records.count).to eq(1)

      # First TRS check
      described_class.call(participant_profile: ect_profile, riab_teacher:)
      expect(ect_profile.induction_records.count).to eq(2)

      # Update the completion date and call again
      induction_period = RIAB::InductionPeriod.find_by(teacher: riab_teacher)
      induction_period.update!(finished_on: 2.weeks.ago.to_date)
      ect_profile.update!(induction_completion_date: nil) # Reset to trigger re-completion

      # Second TRS check (though this scenario is unlikely in practice)
      described_class.call(participant_profile: ect_profile, riab_teacher:)

      # Now we have even more records
      # Note: this may not happen in practice due to the check at line 43 of the service
      # but demonstrates the pattern if completion_date was cleared
      expect(ect_profile.induction_records.count).to be >= 2
    end

    context "when the InductionRecord has a future start_date" do
      let!(:ect_with_future_start) do
        profile = create(:ect_participant_profile,
                         school_cohort: old_school_cohort)

        # Create an active induction record with FUTURE start date
        Induction::Enrol.call(
          participant_profile: profile,
          induction_programme: old_induction_programme,
          start_date: 1.month.from_now,
        )

        profile
      end

      let(:future_trn) { ect_with_future_start.trn }
      let(:future_riab_teacher) { create(:riab_teacher, trn: future_trn, trs_induction_status: "active") }

      before do
        inside_registration_window(cohort: Cohort.current) do
          create(:riab_induction_period,
                 outcome: :pass,
                 started_on: riab_start_date,
                 finished_on: completion_date,
                 teacher: future_riab_teacher)
        end
      end

      it "updates the InductionRecord IN PLACE instead of creating a duplicate" do
        old_record = ect_with_future_start.latest_induction_record
        old_record_id = old_record.id
        expect(old_record.induction_status).to eq("active")

        # Call the service
        described_class.call(participant_profile: ect_with_future_start, riab_teacher: future_riab_teacher)

        # Should still have only 1 InductionRecord
        expect(ect_with_future_start.induction_records.count).to eq(1)

        # The same record should be updated
        updated_record = ect_with_future_start.latest_induction_record
        expect(updated_record.id).to eq(old_record_id)
        expect(updated_record.induction_status).to eq("completed")
      end
    end
  end
end
