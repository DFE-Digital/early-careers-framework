# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BUG: Multiple open InductionRecords created when adding participants", type: :feature, js: true, early_in_cohort: true do
  include DQTHelper

  let(:current_year) { Time.current.year }
  let!(:cohort) { create(:cohort, :current) }
  let!(:school1) { create(:school, name: "First School") }
  let!(:school2) { create(:school, name: "Second School") }
  let!(:appropriate_body) { create(:appropriate_body_national_organisation) }

  let!(:school1_cohort) { create(:school_cohort, school: school1, cohort:, induction_programme_choice: "full_induction_programme", appropriate_body:) }
  let!(:school2_cohort) { create(:school_cohort, school: school2, cohort:, induction_programme_choice: "full_induction_programme", appropriate_body:) }

  let(:lead_provider1) { create(:lead_provider, name: "Provider One") }
  let(:delivery_partner1) { create(:delivery_partner, name: "Delivery Partner One") }
  let!(:partnership1) do
    create(:partnership,
           school: school1,
           lead_provider: lead_provider1,
           delivery_partner: delivery_partner1,
           cohort:,
           challenge_deadline: 2.weeks.ago)
  end

  let(:lead_provider2) { create(:lead_provider, name: "Provider Two") }
  let(:delivery_partner2) { create(:delivery_partner, name: "Delivery Partner Two") }
  let!(:partnership2) do
    create(:partnership,
           school: school2,
           lead_provider: lead_provider2,
           delivery_partner: delivery_partner2,
           cohort:,
           challenge_deadline: 2.weeks.ago)
  end

  let!(:induction_programme1) do
    induction_programme = create(:induction_programme, :fip, school_cohort: school1_cohort, partnership: partnership1)
    school1_cohort.update!(default_induction_programme: induction_programme)
    induction_programme
  end

  let!(:induction_programme2) do
    induction_programme = create(:induction_programme, :fip, school_cohort: school2_cohort, partnership: partnership2)
    school2_cohort.update!(default_induction_programme: induction_programme)
    induction_programme
  end

  let!(:user1) { create(:user, full_name: "First Induction Tutor") }
  let!(:user2) { create(:user, full_name: "Second Induction Tutor") }

  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let!(:sit1) do
    sit = create(:induction_coordinator_profile, schools: [school1], user: user1)
    PrivacyPolicy.current.accept!(user1)
    sit
  end

  let!(:sit2) do
    sit = create(:induction_coordinator_profile, schools: [school2], user: user2)
    PrivacyPolicy.current.accept!(user2)
    sit
  end

  let!(:schedule) { create(:ecf_schedule) }

  let(:ect_full_name) { "Test ECT" }
  let(:ect_trn) { "1234567" }
  let(:ect_dob) { "1998-11-22" }
  let(:ect_email) { "test.ect@email.gov.uk" }

  before do
    disable_cohort_setup_check
  end

  scenario "ECT added at School 1, then added at School 2 creates multiple open InductionRecords" do
    # Set up DQT validation
    create_dqt_record(
      trn: ect_trn,
      name: ect_full_name,
      date_of_birth: Date.parse(ect_dob),
      nino: nil,
    )

    # School 1 SIT adds the ECT
    sign_in_as(user1)
    visit "/schools/#{school1.slug}/cohorts/#{cohort.start_year}"

    click_on "Early career teachers"
    click_on "Add ECT"

    # Who to add
    choose "Early career teacher (ECT)"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: ect_full_name
    click_on "Continue"

    # TRN
    fill_in "Teacher reference number (TRN)", with: ect_trn
    click_on "Continue"

    # DOB
    fill_in "Day", with: "22"
    fill_in "Month", with: "11"
    fill_in "Year", with: "1998"
    click_on "Continue"

    # Email
    fill_in "Email", with: ect_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Confirm appropriate body
    click_on "Confirm"

    # Confirmation page
    expect(page).to have_content("#{ect_full_name} added")

    # Find the participant profile
    ect_profile = ParticipantProfile::ECT.find_by(user: User.find_by(email: ect_email))
    expect(ect_profile).to be_present

    # Should have 1 open InductionRecord at School 1
    open_records_school1 = ect_profile.induction_records.where(end_date: nil)
    expect(open_records_school1.count).to eq(1)
    expect(open_records_school1.first.school).to eq(school1)

    # Sign out
    click_on "Sign out"

    # Now School 2 SIT adds the SAME ECT (using same TRN/DOB)
    sign_in_as(user2)
    visit "/schools/#{school2.slug}/cohorts/#{cohort.start_year}"

    click_on "Early career teachers"
    click_on "Add ECT"

    # Who to add
    choose "Early career teacher (ECT)"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: ect_full_name
    click_on "Continue"

    # TRN
    fill_in "Teacher reference number (TRN)", with: ect_trn
    click_on "Continue"

    # DOB
    fill_in "Day", with: "22"
    fill_in "Month", with: "11"
    fill_in "Year", with: "1998"
    click_on "Continue"

    # Email - can use same or different
    fill_in "Email", with: ect_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Confirm appropriate body
    click_on "Confirm"

    # Confirmation page
    expect(page).to have_content("#{ect_full_name} added")

    # ❌ BUG: Now we have 2 open InductionRecords
    ect_profile.reload
    open_records = ect_profile.induction_records.where(end_date: nil)

    expect(open_records.count).to eq(2), "Expected 2 open InductionRecords (BUG), but got #{open_records.count}"

    # Both at different schools
    schools = open_records.map(&:school)
    expect(schools).to contain_exactly(school1, school2)

    # Both are active status
    expect(open_records.map(&:induction_status).uniq).to eq(%w[active])
  end

  scenario "ECT added to SAME school, then school changes FIP programme creates multiple open InductionRecords" do
    # This scenario demonstrates what happens when:
    # 1. School has FIP with Provider A
    # 2. ECT is added
    # 3. School changes to FIP with Provider B (via UI)
    # 4. Induction::SetCohortInductionProgramme migrates participants but doesn't close old IRs

    # Set up DQT validation
    create_dqt_record(
      trn: ect_trn,
      name: ect_full_name,
      date_of_birth: Date.parse(ect_dob),
      nino: nil,
    )

    # School 1 SIT adds the ECT (creates participant with IR in first programme)
    sign_in_as(user1)
    visit "/schools/#{school1.slug}/cohorts/#{cohort.start_year}"

    click_on "Early career teachers"
    click_on "Add ECT"

    # Who to add
    choose "Early career teacher (ECT)"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: ect_full_name
    click_on "Continue"

    # TRN
    fill_in "Teacher reference number (TRN)", with: ect_trn
    click_on "Continue"

    # DOB
    fill_in "Day", with: "22"
    fill_in "Month", with: "11"
    fill_in "Year", with: "1998"
    click_on "Continue"

    # Email
    fill_in "Email", with: ect_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Confirm appropriate body
    click_on "Confirm"

    # Confirmation page
    expect(page).to have_content("#{ect_full_name} added")

    # Find the participant profile
    ect_profile = ParticipantProfile::ECT.find_by(user: User.find_by(email: ect_email))
    expect(ect_profile).to be_present

    # Should have 1 open InductionRecord at School 1 with Provider 1
    expect(ect_profile.induction_records.where(end_date: nil).count).to eq(1)
    first_ir = ect_profile.induction_records.where(end_date: nil).first
    expect(first_ir.induction_programme).to eq(induction_programme1)

    # Now school changes their programme to a different provider
    # This simulates what happens when a school goes through the UI to change their programme
    create(:partnership,
           school: school1,
           lead_provider: create(:lead_provider, name: "Different Provider"),
           delivery_partner: create(:delivery_partner, name: "Different Delivery"),
           cohort:,
           challenge_deadline: 2.weeks.ago)

    # Call the service that gets triggered when school changes programme via UI
    Induction::SetCohortInductionProgramme.call(
      school_cohort: school1_cohort,
      programme_choice: "full_induction_programme",
    )

    # The SetCohortInductionProgramme service calls MigrateParticipantsToNewProgramme
    # which internally calls Induction::Enrol without closing the previous IR

    # ❌ BUG: Now we have 2 open InductionRecords at the SAME school
    ect_profile.reload
    open_records = ect_profile.induction_records.where(end_date: nil)

    expect(open_records.count).to eq(2), "Expected 2 open InductionRecords at SAME school (BUG), but got #{open_records.count}"

    # Both at same school, different programmes
    expect(open_records.map(&:school).uniq.count).to eq(1)
    expect(open_records.first.school).to eq(school1)

    # Two different programmes (different partnerships)
    programmes = open_records.map(&:induction_programme).uniq
    expect(programmes.count).to eq(2)

    # Both are active status
    expect(open_records.map(&:induction_status).uniq).to eq(%w[active])
  end

  # NOTE: This test demonstrates the bug triggered by the EnrolSchoolCohortsJob cron job (runs at 3am daily).
  # Unlike the other tests, this is not triggered by direct UI actions, but it's still a valid bug scenario.
  # The job processes schools that have set an induction_programme_choice but don't have any induction_programmes yet.
  scenario "ECT enrolled, then EnrolSchoolCohortsJob runs creating multiple open InductionRecords at SAME school" do
    # This scenario demonstrates what happens when:
    # 1. A participant is manually enrolled in a programme
    # 2. The school cohort has a programme choice but no default programme
    # 3. EnrolSchoolCohortsJob runs (cron job at 3am) and creates a new programme + re-enrolls all participants

    # Set up DQT validation
    create_dqt_record(
      trn: ect_trn,
      name: ect_full_name,
      date_of_birth: Date.parse(ect_dob),
      nino: nil,
    )

    # Remove the default induction programme to simulate a school without one
    school1_cohort.update!(default_induction_programme: nil)
    induction_programme1.destroy!

    # School 1 SIT adds the ECT (this creates participant but NO induction record since no programme)
    sign_in_as(user1)
    visit "/schools/#{school1.slug}/cohorts/#{cohort.start_year}"

    click_on "Early career teachers"
    click_on "Add ECT"

    # Who to add
    choose "Early career teacher (ECT)"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: ect_full_name
    click_on "Continue"

    # TRN
    fill_in "Teacher reference number (TRN)", with: ect_trn
    click_on "Continue"

    # DOB
    fill_in "Day", with: "22"
    fill_in "Month", with: "11"
    fill_in "Year", with: "1998"
    click_on "Continue"

    # Email
    fill_in "Email", with: ect_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Confirm appropriate body
    click_on "Confirm"

    # Confirmation page
    expect(page).to have_content("#{ect_full_name} added")

    # Find the participant profile
    ect_profile = ParticipantProfile::ECT.find_by(user: User.find_by(email: ect_email))
    expect(ect_profile).to be_present

    # No InductionRecord yet since school has no default programme
    expect(ect_profile.induction_records.count).to eq(0)

    # Now manually enroll the ECT in a programme (creating first IR)
    # This could happen via admin console or other manual intervention
    first_programme = create(:induction_programme, :fip, school_cohort: school1_cohort, partnership: partnership1)
    Induction::Enrol.call(
      participant_profile: ect_profile,
      induction_programme: first_programme,
    )

    # Should have 1 open InductionRecord at School 1
    expect(ect_profile.induction_records.where(end_date: nil).count).to eq(1)

    # Set school cohort to have FIP choice but no default programme
    # This makes it eligible for EnrolSchoolCohortsJob to process (lines 5-8 of job)
    school1_cohort.update!(
      induction_programme_choice: "full_induction_programme",
      default_induction_programme: nil,
    )

    # Now run EnrolSchoolCohortsJob which will create a NEW programme and re-enroll all participants
    # This is the cron job that runs at 3am daily (config/sidekiq_cron_schedule.yml:22)
    EnrolSchoolCohortsJob.new.perform

    # ❌ BUG: Now we have 2 open InductionRecords at the SAME school
    ect_profile.reload
    open_records = ect_profile.induction_records.where(end_date: nil)

    expect(open_records.count).to eq(2), "Expected 2 open InductionRecords at SAME school (BUG), but got #{open_records.count}"

    # Both at same school, different programmes
    expect(open_records.map(&:school).uniq.count).to eq(1)
    expect(open_records.first.school).to eq(school1)

    # Two different programmes
    programmes = open_records.map(&:induction_programme).uniq
    expect(programmes.count).to eq(2)

    # Both are active status
    expect(open_records.map(&:induction_status).uniq).to eq(%w[active])
  end

  scenario "Mentor added at School 1, then added at School 2 creates multiple open InductionRecords" do
    mentor_full_name = "Test Mentor"
    mentor_trn = "7654321"
    mentor_dob = "1990-05-15"
    mentor_email = "test.mentor@email.gov.uk"

    # Set up DQT validation
    create_dqt_record(
      trn: mentor_trn,
      name: mentor_full_name,
      date_of_birth: Date.parse(mentor_dob),
      nino: nil,
    )

    # School 1 SIT adds the Mentor
    sign_in_as(user1)
    visit "/schools/#{school1.slug}/cohorts/#{cohort.start_year}"

    click_on "Mentors"
    click_on "Add mentor"

    # Who to add
    choose "Mentor"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: mentor_full_name
    click_on "Continue"

    # Email
    fill_in "Email", with: mentor_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Choose providers
    choose "My school has decided they will train with #{lead_provider1.name} and #{delivery_partner1.name}"
    click_on "Continue"

    # Confirmation page
    expect(page).to have_content("#{mentor_full_name} added")

    # Find the participant profile
    mentor_profile = ParticipantProfile::Mentor.find_by(user: User.find_by(email: mentor_email))
    expect(mentor_profile).to be_present

    # Should have 1 open InductionRecord at School 1
    open_records_school1 = mentor_profile.induction_records.where(end_date: nil)
    expect(open_records_school1.count).to eq(1)
    expect(open_records_school1.first.school).to eq(school1)

    # Sign out
    click_on "Sign out"

    # Now School 2 SIT adds the SAME Mentor
    sign_in_as(user2)
    visit "/schools/#{school2.slug}/cohorts/#{cohort.start_year}"

    click_on "Mentors"
    click_on "Add mentor"

    # Who to add
    choose "Mentor"
    click_on "Continue"

    # What we need
    click_on "Continue"

    # Name
    fill_in "Full name", with: mentor_full_name
    click_on "Continue"

    # Email
    fill_in "Email", with: mentor_email
    click_on "Continue"

    # When did they start
    choose "The start of the #{cohort.academic_year_start_date.strftime('%-d %B %Y')} cohort"
    click_on "Continue"

    # Choose providers
    choose "My school has decided they will train with #{lead_provider2.name} and #{delivery_partner2.name}"
    click_on "Continue"

    # Confirmation page
    expect(page).to have_content("#{mentor_full_name} added")

    # ❌ BUG: Now we have 2 open InductionRecords
    mentor_profile.reload
    open_records = mentor_profile.induction_records.where(end_date: nil)

    expect(open_records.count).to eq(2), "Expected 2 open InductionRecords (BUG), but got #{open_records.count}"

    # Both at different schools
    schools = open_records.map(&:school)
    expect(schools).to contain_exactly(school1, school2)

    # Both are active status
    expect(open_records.map(&:induction_status).uniq).to eq(%w[active])
  end

private

  def sign_in_as(user)
    visit "/users/sign_in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_on "Sign in"
  end

  def create_dqt_record(trn:, name:, date_of_birth:, nino: nil)
    allow_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(
      ParticipantValidationService::ParticipantValidationResult.new(
        trn:,
        full_name: name,
        date_of_birth:,
        nino:,
        validated: true,
      ),
    )
  end
end
