# frozen_string_literal: true

RSpec.feature "Participant validation journey", with_feature_flags: { eligibility_notifications: "active" }, type: :feature, js: true do
  let(:school) { create :school, name: "Awesome school" }
  let(:school_cohort) { create :school_cohort, :fip, school: school }
  let(:ect_user) { create :user, full_name: "Lena zavroni" }
  let(:mentor_user) { create :user, full_name: "Spike Spiegel" }
  let(:ect_teacher_profile) { create :teacher_profile, user: ect_user }
  let(:mentor_teacher_profile) { create :teacher_profile, user: mentor_user }
  let(:ect_participant_profile) { create :ect_participant_profile, school_cohort: school_cohort, teacher_profile: ect_teacher_profile }
  let(:mentor_participant_profile) { create :mentor_participant_profile, school_cohort: school_cohort, teacher_profile: mentor_teacher_profile }

  before { set_dtq_validation_result nil }

  scenario "ECT validates their details with trn" do
    sign_in_as ect_participant_profile.user
    expect(page).to have_current_path participants_validation_step_path(:trn)
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: trn")

    click_on "Continue"
    expect(page).to have_content "Enter your teacher reference number"

    fill_in "Teacher reference number (TRN)", with: "1234567"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:dob)
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: dob")

    fill_in "Day", with: "29"
    fill_in "Month", with: "2"
    fill_in "Year", with: "1983"
    click_on "Continue"

    expect(page).to have_content "Enter valid date of birth"
    fill_in "Day", with: "28"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: no-match after trn")
    click_on "Add your National Insurance number"

    expect(page).to have_current_path participants_validation_step_path(:nino)
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: nino")
    click_on "Continue"

    expect(page).to have_content "Enter your National Insurance Number"
    fill_in "National Insurance Number", with: "AB123456C"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: no-match after trn and nino")
    click_on "Continue to confirm your name"

    expect(page).to have_current_path participants_validation_step_path(:"name-changed")
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: name changed")

    click_on "Continue"
    expect(page).to have_content "Select how you want to continue"

    find(:label, text: "No").click
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:name)
    expect(page).to be_accessible

    page.percy_snapshot("Participant validation journey: name")
    expect(page.find_field("Your name").value).to eq ect_participant_profile.user.full_name
    fill_in "Your name", with: "Correct Name"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: no-match after trn, nino and name change")
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"manual-check")
    expect(page).to be_accessible
    page.percy_snapshot("Participant validation journey: manual check required")
  end

  scenario "Mentor tries to validate but has no TRN" do
    sign_in_as mentor_participant_profile.user
    expect(page).to have_current_path participants_validation_step_path(:"check-trn-given")
    expect(page).to be_accessible
    page.percy_snapshot("Mentor validation journey: trn")

    click_on "Continue"
    expect(page).to have_content "Select an option"

    find(:label, text: "No").click
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"get-a-trn")
    expect(page).to be_accessible
    page.percy_snapshot("Mentor validation journey: trn guidance")
  end

  scenario "Mentor validates their details with trn" do
    sign_in_as mentor_participant_profile.user
    expect(page).to have_current_path participants_validation_step_path(:"check-trn-given")

    find(:label, text: "Yes").click
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:trn)

    click_on "Continue"
    expect(page).to have_content "Enter your teacher reference number"

    fill_in "Teacher reference number (TRN)", with: "7654321"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:dob)

    fill_in "Day", with: "4"
    fill_in "Month", with: "11"
    fill_in "Year", with: "1991"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    click_on "Add your National Insurance number"
    expect(page).to have_current_path participants_validation_step_path(:nino)
    click_on "Continue"

    fill_in "National Insurance Number", with: "AB123456C"
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    click_on "Continue to confirm your name"

    expect(page).to have_current_path participants_validation_step_path(:"name-changed")
    find(:label, text: "Yes").click
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"no-match")
    click_on "Continue"

    expect(page).to have_current_path participants_validation_step_path(:"manual-check")
  end

  def set_dtq_validation_result(result)
    allow(ParticipantValidationService).to receive(:validate).and_return result
  end
end
