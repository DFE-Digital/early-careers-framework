# frozen_string_literal: true

RSpec.describe "Bug Investigation: Multiple Open Induction Records" do
  let(:cohort) { create(:cohort, :current) }
  let(:old_school) { create(:school, name: "Old School") }
  let(:new_school) { create(:school, name: "New School") }
  let(:old_school_cohort) { create(:school_cohort, school: old_school, cohort:) }
  let(:new_school_cohort) { create(:school_cohort, school: new_school, cohort:) }

  let!(:old_induction_programme) { create(:induction_programme, :fip, school_cohort: old_school_cohort) }
  let!(:new_induction_programme) { create(:induction_programme, :fip, school_cohort: new_school_cohort) }

  describe "EarlyCareerTeachers::Create protections" do
    let(:user) { create(:user, full_name: "Jane Smith", email: "jane.smith@example.com") }
    let(:teacher_profile) { create(:teacher_profile, user:, school: old_school) }

    let!(:existing_ect_profile) do
      create(:ect_participant_profile,
             teacher_profile:,
             school_cohort: old_school_cohort,
             induction_completion_date: 6.months.ago)
    end

    let!(:existing_induction_record) do
      record = Induction::Enrol.call(
        participant_profile: existing_ect_profile,
        induction_programme: old_induction_programme,
        start_date: 2.years.ago,
      )
      record.update!(induction_status: :completed)
      record
    end

    context "when the user tries to register at a new school with the SAME email" do
      it "raises ParticipantProfileExistsError because it finds the existing profile" do
        expect {
          EarlyCareerTeachers::Create.call(
            full_name: "Jane Smith",
            email: user.email,
            school_cohort: new_school_cohort,
          )
        }.to raise_error(EarlyCareerTeachers::Create::ParticipantProfileExistsError)
      end
    end

    context "when trying to register with a DIFFERENT email (not yet in identities)" do
      let(:completely_new_email) { "jane.smith.brand.new@newschool.com" }

      it "DOES NOT raise an error - creates a NEW profile (POTENTIAL BUG)" do
        # This demonstrates a potential gap: if someone uses a completely new email
        # that hasn't been added to the user's identities yet, the check doesn't catch it
        expect {
          new_profile = EarlyCareerTeachers::Create.call(
            full_name: "Jane Smith",
            email: completely_new_email,
            school_cohort: new_school_cohort,
          )

          # A new profile is created
          expect(new_profile).to be_a(ParticipantProfile::ECT)
          expect(new_profile.user.email).to eq(completely_new_email)

          # Now this user has TWO ECT profiles (if they're actually the same person)
          # The check at line 95 looks for profiles through user.participant_identities
          # But since this is a DIFFERENT user (new email creates new user via find_or_create_by!)
          # it doesn't catch the duplicate
        }.not_to raise_error
      end

      it "shows the limitation: new email creates a NEW User object" do
        # The issue: User.find_or_create_by!(email:) creates a NEW user
        # So the participant_profile_exists? check looks at a DIFFERENT user
        user1 = User.find_or_create_by!(email: user.email)
        user2 = User.find_or_create_by!(email: completely_new_email) do |u|
          u.full_name = "Jane Smith"
        end

        expect(user1).to eq(user)
        expect(user2).not_to eq(user)
        expect(user2).to be_a(User)

        # So the check won't find the existing profile because it's looking at user2
        # while the existing profile belongs to user1
      end
    end
  end

  describe "BUG DEMONSTRATION: Induction::Enrol does NOT close previous records" do
    let!(:completed_ect) do
      profile = create(:ect_participant_profile,
                       school_cohort: old_school_cohort,
                       induction_completion_date: 1.year.ago)

      # Create an open induction record (completed but left open)
      Induction::Enrol.call(
        participant_profile: profile,
        induction_programme: old_induction_programme,
        start_date: 3.years.ago,
      ).tap do |record|
        record.update!(induction_status: :completed)
      end

      profile
    end

    it "Induction::Enrol leaves the previous InductionRecord OPEN - this is by design" do
      # Initial state: one open completed record
      old_record = completed_ect.latest_induction_record
      expect(old_record.end_date).to be_nil
      expect(old_record.induction_status).to eq("completed")
      expect(old_record.school).to eq(old_school)

      # Now call Induction::Enrol again for a different school
      # This simulates what EarlyCareerTeachers::Create does internally
      new_record = Induction::Enrol.call(
        participant_profile: completed_ect,
        induction_programme: new_induction_programme,
        start_date: Time.zone.now,
      )

      # THE ISSUE: The old InductionRecord is still open (end_date is nil)
      old_record.reload
      expect(old_record.end_date).to be_nil # ❌ Still open

      # The new record is also open
      expect(new_record.end_date).to be_nil
      expect(new_record.induction_status).to eq("completed")
      expect(new_record.school).to eq(new_school)

      # Now the participant has TWO open InductionRecords at different schools
      open_records = completed_ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2)

      schools = open_records.map(&:school)
      expect(schools).to contain_exactly(old_school, new_school)
    end
  end

  describe "COMPARISON: How transfer wizards handle it correctly" do
    let!(:completed_ect_profile) do
      profile = create(:ect_participant_profile,
                       school_cohort: old_school_cohort,
                       induction_completion_date: 6.months.ago)

      Induction::Enrol.call(
        participant_profile: profile,
        induction_programme: old_induction_programme,
        start_date: 2.years.ago,
      ).tap do |record|
        # Leave as active status initially - TransferToSchoolsProgramme expects active
        record.update!(induction_status: :active)
      end

      profile
    end

    it "TransferToSchoolsProgramme CORRECTLY closes the previous record" do
      old_record = completed_ect_profile.latest_induction_record
      expect(old_record.end_date).to be_nil
      expect(old_record.induction_status).to eq("active")

      # Use the transfer service
      new_record = Induction::TransferToSchoolsProgramme.call(
        participant_profile: completed_ect_profile,
        induction_programme: new_induction_programme,
        start_date: Time.zone.now,
      )

      # ✅ CORRECT: The old record is properly closed with leaving status
      old_record.reload
      expect(old_record.end_date).not_to be_nil
      expect(old_record.induction_status).to eq("leaving")

      # The new record is created with completed status (because participant has induction_completion_date)
      expect(new_record.induction_status).to eq("completed")
      expect(new_record.school).to eq(new_school)
      expect(new_record.end_date).to be_nil

      # Only ONE open record remains
      open_records = completed_ect_profile.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(1)
      expect(open_records.first.school).to eq(new_school)
    end
  end

  describe "Evidence: Multiple open InductionRecords" do
    let!(:completed_ect) do
      profile = create(:ect_participant_profile,
                       school_cohort: old_school_cohort,
                       induction_completion_date: 1.year.ago)

      # Create first induction record at old school (completed but left open)
      Induction::Enrol.call(
        participant_profile: profile,
        induction_programme: old_induction_programme,
        start_date: 3.years.ago,
      ).tap do |record|
        record.update!(induction_status: :completed)
      end

      profile
    end

    it "using Induction::Enrol directly creates multiple open records" do
      # Initial state: one open record
      expect(completed_ect.induction_records.where(end_date: nil).count).to eq(1)

      # "Transfer" to new school using Induction::Enrol directly
      # This is what happens internally in EarlyCareerTeachers::Create
      Induction::Enrol.call(
        participant_profile: completed_ect,
        induction_programme: new_induction_programme,
        start_date: Time.zone.now,
      )

      # Result: TWO open InductionRecords
      open_records = completed_ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(2)

      # Both are for different schools
      schools = open_records.map(&:school)
      expect(schools).to contain_exactly(old_school, new_school)

      # Both have completed status
      statuses = open_records.map(&:induction_status)
      expect(statuses).to all(eq("completed"))
    end

    it "using TransferToSchoolsProgramme correctly maintains only one open record" do
      # Change the status to active so transfer service will process it
      completed_ect.latest_induction_record.update!(induction_status: :active)

      # Initial state: one open record
      expect(completed_ect.induction_records.where(end_date: nil).count).to eq(1)

      # Transfer using the correct service
      Induction::TransferToSchoolsProgramme.call(
        participant_profile: completed_ect,
        induction_programme: new_induction_programme,
        start_date: Time.zone.now,
      )

      # ✅ CORRECT: Still only ONE open InductionRecord
      open_records = completed_ect.induction_records.where(end_date: nil)
      expect(open_records.count).to eq(1)

      # It's for the new school
      expect(open_records.first.school).to eq(new_school)

      # The old record is closed
      old_record = completed_ect.induction_records.joins(:induction_programme)
        .where(induction_programmes: { school_cohort_id: old_school_cohort.id }).first
      expect(old_record.end_date).not_to be_nil
      expect(old_record.induction_status).to eq("leaving")
    end
  end
end
