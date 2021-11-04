# frozen_string_literal: true

RSpec.feature "ECT participant validation journey", with_feature_flags: { eligibility_notifications: "active" }, type: :feature, js: true do
  let(:school) { create :school, name: "Awesome school" }
  let(:school_cohort) { create :school_cohort, :fip, school: school }
  let(:user) { create :user, full_name: "Lena zavroni" }
  let(:teacher_profile) { create :teacher_profile, user: user }
  let(:participant_profile) { create :participant_profile, :ect, school_cohort: school_cohort, teacher_profile: teacher_profile }
  before { set_dtq_validation_result nil }

  scenario "Participant validates their details with trn" do
    sign_in_as participant_profile.user
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
    expect(page.find_field("Your name").value).to eq participant_profile.user.full_name
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

  def set_dtq_validation_result(result)
    allow(ParticipantValidationService).to receive(:validate).and_return result
  end
end
