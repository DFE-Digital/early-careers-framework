# frozen_string_literal: true

RSpec.describe "Re-enrolling a completed participant" do
  let(:cohort) { create(:cohort, :current) }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:, cohort:, appropriate_body: create(:appropriate_body_local_authority)) }
  let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }

  describe "when an ECT with completed induction is re-registered at a school" do
    let(:teacher_profile) { create(:teacher_profile) }
    let!(:ect_profile) do
      create(:ect_participant_profile,
             teacher_profile:,
             school_cohort:,
             induction_completion_date: 6.months.ago)
    end

    let!(:existing_completed_record) do
      Induction::Enrol.call(
        participant_profile: ect_profile,
        induction_programme: create(:induction_programme, :fip, school_cohort: create(:school_cohort, school: create(:school), cohort:)),
        start_date: 2.years.ago,
      )
    end

    before do
      # Mark the existing record as completed
      existing_completed_record.update!(induction_status: :completed, end_date: 6.months.ago)
    end

    context "when enrolling at a new school" do
      let(:new_school_cohort) { create(:school_cohort, school: create(:school, name: "New School"), cohort:) }
      let(:new_induction_programme) { create(:induction_programme, :fip, school_cohort: new_school_cohort) }

      it "creates a new induction record with completed status" do
        new_record = Induction::Enrol.call(
          participant_profile: ect_profile,
          induction_programme: new_induction_programme,
          start_date: Time.zone.now,
        )

        expect(new_record).to be_completed_induction_status
      end

      it "does not change the participant profile training_status" do
        expect {
          Induction::Enrol.call(
            participant_profile: ect_profile,
            induction_programme: new_induction_programme,
            start_date: Time.zone.now,
          )
        }.not_to change(ect_profile, :training_status)
      end

      it "does not change the participant profile status" do
        expect {
          Induction::Enrol.call(
            participant_profile: ect_profile,
            induction_programme: new_induction_programme,
            start_date: Time.zone.now,
          )
        }.not_to change(ect_profile, :status)
      end

      it "does not create a new participant_profile_state record" do
        expect {
          Induction::Enrol.call(
            participant_profile: ect_profile,
            induction_programme: new_induction_programme,
            start_date: Time.zone.now,
          )
        }.not_to change(ParticipantProfileState, :count)
      end

      it "preserves the induction completion date" do
        Induction::Enrol.call(
          participant_profile: ect_profile,
          induction_programme: new_induction_programme,
          start_date: Time.zone.now,
        )

        expect(ect_profile.reload.induction_completion_date).to eq(ect_profile.induction_completion_date)
      end
    end
  end

  describe "when a Mentor with completed induction is assigned to an ECT" do
    let(:teacher_profile) { create(:teacher_profile) }
    let!(:mentor_profile) do
      create(:mentor_participant_profile,
             teacher_profile:,
             school_cohort:,
             mentor_completion_date: 1.year.ago)
    end

    let!(:existing_completed_record) do
      record = Induction::Enrol.call(
        participant_profile: mentor_profile,
        induction_programme: create(:induction_programme, :fip, school_cohort: create(:school_cohort, school: create(:school), cohort:)),
        start_date: 3.years.ago,
      )
      record.update!(induction_status: :completed, end_date: 1.year.ago)
      record
    end

    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }

    before do
      Induction::Enrol.call(
        participant_profile: ect_profile,
        induction_programme:,
        start_date: Time.zone.now,
      )
    end

    context "when mentor is enrolled at a new school to mentor ECTs" do
      it "creates a new induction record with completed status" do
        new_record = Induction::Enrol.call(
          participant_profile: mentor_profile,
          induction_programme:,
          start_date: Time.zone.now,
          mentor_profile: nil,
        )

        expect(new_record).to be_completed_induction_status
      end

      it "allows the completed mentor to be added to the school's mentor pool" do
        expect {
          Mentors::AddToSchool.call(
            mentor_profile:,
            school:,
          )
        }.to change { school.school_mentors.count }.by(1)
      end

      it "allows assigning the completed mentor to an ECT" do
        Mentors::AddToSchool.call(mentor_profile:, school:)

        # Update the ECT's current induction record to assign the mentor
        ect_current_record = ect_profile.current_induction_record
        ect_current_record.update!(mentor_profile:)

        expect(ect_current_record.reload.mentor_profile).to eq(mentor_profile)
      end

      it "does not change the mentor's training_status when added to school" do
        expect {
          Mentors::AddToSchool.call(
            mentor_profile:,
            school:,
          )
        }.not_to change(mentor_profile, :training_status)
      end

      it "does not create a new participant_profile_state when enrolled at new school" do
        expect {
          Induction::Enrol.call(
            participant_profile: mentor_profile,
            induction_programme:,
            start_date: Time.zone.now,
          )
        }.not_to change(ParticipantProfileState, :count)
      end
    end
  end

  describe "edge cases for completed participants" do
    let(:teacher_profile) { create(:teacher_profile) }
    let(:completed_ect) do
      create(:ect_participant_profile,
             teacher_profile:,
             school_cohort:,
             induction_completion_date: 3.months.ago)
    end

    before do
      record = Induction::Enrol.call(
        participant_profile: completed_ect,
        induction_programme:,
        start_date: 2.years.ago,
      )
      record.update!(induction_status: :completed, end_date: 3.months.ago)
    end

    it "completed_training? returns true for participants with induction_completion_date" do
      expect(completed_ect.completed_training?).to be true
    end

    it "allows multiple re-enrollments at different schools with completed status" do
      school_2 = create(:school, name: "School 2")
      school_cohort_2 = create(:school_cohort, school: school_2, cohort:)
      programme_2 = create(:induction_programme, :fip, school_cohort: school_cohort_2)

      school_3 = create(:school, name: "School 3")
      school_cohort_3 = create(:school_cohort, school: school_3, cohort:)
      programme_3 = create(:induction_programme, :fip, school_cohort: school_cohort_3)

      record_2 = Induction::Enrol.call(
        participant_profile: completed_ect,
        induction_programme: programme_2,
        start_date: Time.zone.now,
      )

      record_3 = Induction::Enrol.call(
        participant_profile: completed_ect,
        induction_programme: programme_3,
        start_date: 1.week.from_now,
      )

      expect(record_2).to be_completed_induction_status
      expect(record_3).to be_completed_induction_status
      expect(completed_ect.induction_records.count).to eq(3)
    end

    it "maintains separate induction records for each school enrollment" do
      new_school_cohort = create(:school_cohort, school: create(:school), cohort:)
      new_programme = create(:induction_programme, :fip, school_cohort: new_school_cohort)

      expect {
        Induction::Enrol.call(
          participant_profile: completed_ect,
          induction_programme: new_programme,
          start_date: Time.zone.now,
        )
      }.to change { completed_ect.induction_records.count }.by(1)
    end

    it "BUG INVESTIGATION: What if the first completed IR has NO end_date?" do
      # Create a participant with completion date
      ect = create(:ect_participant_profile,
                   school_cohort:,
                   induction_completion_date: 1.year.ago)

      # Enroll at first school - this creates a completed IR
      school1_cohort = create(:school_cohort, school: create(:school, name: "School 1"), cohort:)
      programme1 = create(:induction_programme, :fip, school_cohort: school1_cohort)

      ir1 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 2.years.ago,
      )

      # Check: Does the completed IR have an end_date?
      expect(ir1.induction_status).to eq("completed")
      expect(ir1.end_date).to be_nil # NO end_date by default!

      # Now enroll at second school
      school2_cohort = create(:school_cohort, school: create(:school, name: "School 2"), cohort:)
      programme2 = create(:induction_programme, :fip, school_cohort: school2_cohort)

      ir2 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme2,
        start_date: 1.year.ago,
      )

      # Check: Now we have 2 IRs, both completed, BOTH with no end_date
      ect.reload
      expect(ect.induction_records.count).to eq(2)

      open_records = ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2) # ❌ BUG: Multiple open IRs

      expect(ir1.induction_status).to eq("completed")
      expect(ir1.end_date).to be_nil

      expect(ir2.induction_status).to eq("completed")
      expect(ir2.end_date).to be_nil
    end

    it "BUG: Participant enrolled at multiple schools, THEN completes induction" do
      # Create a participant WITHOUT completion date (active ECT)
      ect = create(:ect_participant_profile,
                   school_cohort:,
                   induction_completion_date: nil)

      # Enroll at School 1 - creates ACTIVE IR
      school1_cohort = create(:school_cohort, school: create(:school, name: "School 1"), cohort:)
      programme1 = create(:induction_programme, :fip, school_cohort: school1_cohort)

      ir1 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 2.years.ago,
      )

      expect(ir1.induction_status).to eq("active")
      expect(ir1.end_date).to be_nil

      # Enroll at School 2 - creates ANOTHER ACTIVE IR (Bug #1: doesn't close first)
      school2_cohort = create(:school_cohort, school: create(:school, name: "School 2"), cohort:)
      programme2 = create(:induction_programme, :fip, school_cohort: school2_cohort)

      ir2 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme2,
        start_date: 1.year.ago,
      )

      expect(ir2.induction_status).to eq("active")
      expect(ir2.end_date).to be_nil

      # Now we have 2 open ACTIVE IRs
      expect(ect.induction_records.where(end_date: nil).count).to eq(2)

      # NOW the participant completes induction
      ect.update!(induction_completion_date: 1.month.ago)

      # Enroll at School 3 - should create COMPLETED IR
      school3_cohort = create(:school_cohort, school: create(:school, name: "School 3"), cohort:)
      programme3 = create(:induction_programme, :fip, school_cohort: school3_cohort)

      Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme3,
        start_date: Time.zone.now,
      )

      # ❌ BUG: Now we have 3 open IRs - 2 active + 1 completed
      ect.reload
      open_records = ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(3)

      active_irs = open_records.where(induction_status: :active)
      completed_irs = open_records.where(induction_status: :completed)

      expect(active_irs.count).to eq(2) # School 1 & 2
      expect(completed_irs.count).to eq(1) # School 3

      # This matches Nathan's pattern if we only look at 2 of the IRs:
      # x1 IR with induction_status = completed
      # x1 IR with induction_status <> completed (active)
      # both have null end_date
    end

    it "BUG CONFIRMED: Exact pattern Nathan described - 1 completed + 1 active, both open" do
      # Create active participant
      ect = create(:ect_participant_profile,
                   school_cohort:,
                   induction_completion_date: nil)

      # Enroll at School 1 - ACTIVE IR
      school1_cohort = create(:school_cohort, school: create(:school, name: "School 1"), cohort:)
      programme1 = create(:induction_programme, :fip, school_cohort: school1_cohort)

      ir1 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 2.years.ago,
      )

      # Participant completes
      ect.update!(induction_completion_date: 1.month.ago)

      # Enroll at School 2 - COMPLETED IR (doesn't close School 1's IR)
      school2_cohort = create(:school_cohort, school: create(:school, name: "School 2"), cohort:)
      programme2 = create(:induction_programme, :fip, school_cohort: school2_cohort)

      ir2 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme2,
        start_date: 1.month.ago,
      )

      # ❌ BUG CONFIRMED: Exact pattern Nathan described
      ect.reload
      open_records = ect.induction_records.where(end_date: nil)

      expect(open_records.count).to eq(2)

      # x1 IR with induction_status = completed
      completed_ir = open_records.find_by(induction_status: :completed)
      expect(completed_ir).not_to be_nil
      expect(completed_ir.end_date).to be_nil
      expect(completed_ir.id).to eq(ir2.id)

      # x1 IR with induction_status <> completed
      active_ir = open_records.find { |ir| ir.induction_status != "completed" }
      expect(active_ir).not_to be_nil
      expect(active_ir.induction_status).to eq("active")
      expect(active_ir.end_date).to be_nil
      expect(active_ir.id).to eq(ir1.id)

      # different start dates for each IR
      expect(ir1.start_date).not_to eq(ir2.start_date)

      # Both have null end_date
      expect([ir1, ir2].all? { |ir| ir.end_date.nil? }).to be true
    end

    it "BUG: Can create multiple open IRs at the SAME school" do
      # Create active participant
      ect = create(:ect_participant_profile,
                   school_cohort:,
                   induction_completion_date: nil)

      school1_cohort = create(:school_cohort, school: create(:school, name: "Test School"), cohort:)
      programme1 = create(:induction_programme, :fip, school_cohort: school1_cohort)

      # Enroll at School 1 - first time
      ir1 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 2.years.ago,
      )

      expect(ir1.induction_status).to eq("active")
      expect(ir1.school).to eq(school1_cohort.school)

      # Enroll at SAME SCHOOL again - no validation prevents this!
      ir2 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 1.year.ago,
      )

      expect(ir2.induction_status).to eq("active")
      expect(ir2.school).to eq(school1_cohort.school)

      # ❌ BUG: Now we have 2 open IRs at the SAME school
      ect.reload
      open_records = ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2)

      # Both IRs are at the same school
      schools = open_records.map(&:school).uniq
      expect(schools.count).to eq(1)
      expect(schools.first.name).to eq("Test School")

      # Different start dates
      expect(ir1.start_date).not_to eq(ir2.start_date)

      # Both have null end_date
      expect(ir1.end_date).to be_nil
      expect(ir2.end_date).to be_nil
    end

    it "BUG: Same school, participant becomes completed between enrollments" do
      # Create active participant
      ect = create(:ect_participant_profile,
                   school_cohort:,
                   induction_completion_date: nil)

      school1_cohort = create(:school_cohort, school: create(:school, name: "Test School"), cohort:)
      programme1 = create(:induction_programme, :fip, school_cohort: school1_cohort)

      # Enroll at School 1 - ACTIVE
      ir1 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 2.years.ago,
      )

      expect(ir1.induction_status).to eq("active")

      # Participant completes
      ect.update!(induction_completion_date: 1.month.ago)

      # Enroll at SAME SCHOOL again - now COMPLETED (maybe after changing programme?)
      ir2 = Induction::Enrol.call(
        participant_profile: ect,
        induction_programme: programme1,
        start_date: 1.week.ago,
      )

      expect(ir2.induction_status).to eq("completed")

      # ❌ BUG: 2 open IRs at same school - 1 active + 1 completed
      ect.reload
      open_records = ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2)

      # Both at same school
      expect(open_records.map(&:school).uniq.count).to eq(1)

      # Different statuses
      statuses = open_records.map(&:induction_status).sort
      expect(statuses).to eq(%w[active completed])
    end
  end

  describe "Induction::Enrol behavior with multiple calls" do
    it "BUG: Induction::Enrol has no duplicate prevention - calling it multiple times creates multiple open IRs" do
      # This test demonstrates the core issue: Induction::Enrol.call creates new InductionRecords
      # without any validation to prevent duplicates or close previous records

      ect = create(:ect_participant_profile, school_cohort:)

      # Call Induction::Enrol 5 times for the same participant and programme
      5.times do |i|
        Induction::Enrol.call(
          participant_profile: ect,
          induction_programme:,
          start_date: i.days.ago,
        )
      end

      # ❌ BUG: 5 open IRs created
      expect(ect.induction_records.where(end_date: nil).count).to eq(5)

      # All at same school
      expect(ect.induction_records.map(&:school).uniq.count).to eq(1)

      # This is the root cause of the bug: Induction::Enrol is a low-level service
      # that just does InductionRecord.create! with no validation to prevent duplicates
      # or logic to close previous records.
      #
      # Higher-level services that call Induction::Enrol are responsible for:
      # 1. Checking if an open IR already exists
      # 2. Closing previous IRs before creating new ones
      # 3. Preventing duplicate enrollments
      #
      # Services that do this correctly:
      # - Induction::ChangeProgramme (calls changing! to close previous IR)
      # - Induction::TransferToSchoolsProgramme (calls leaving! to close previous IR)
      # - EarlyCareerTeachers::Reactivate (calls end_current_induction_record)
      #
      # For bug demonstrations with actual service calls, see:
      # - spec/jobs/enrol_school_cohorts_job_spec.rb (EnrolSchoolCohortsJob bug test)
      # - spec/features/schools/participants/add_participants/bug_multiple_open_induction_periods_spec.rb (e2e tests)
    end
  end
end
