# frozen_string_literal: true

RSpec.describe "SIT removing participants from the cohort", js: true, with_feature_flags: { eligibility_notifications: "active" } do
  let(:sit_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }
  let(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
  let(:mentor_user) { create :user, :teacher, full_name: "John Doe", email: "john-doe@example.com" }
  let!(:mentor_profile) { create(:participant_profile, :mentor, request_for_details_sent_at: Date.new(2021, 9, 9), school_cohort: school_cohort, teacher_profile: mentor_user.teacher_profile) }
  let(:ect_user) { create :user, :teacher, full_name: "John Smith", email: "john-smith@example.com" }
  let!(:ect_profile) { create(:participant_profile, :ect, school_cohort: school_cohort, mentor_profile: mentor_profile, teacher_profile: ect_user.teacher_profile) }
  let!(:ineligible_ect_profile) { create(:participant_profile, :ect, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort, teacher_profile: ineligible_user.teacher_profile) }
  let(:ineligible_user) { create :user, :teacher, full_name: "Kate Edwards", email: "kate-edwards@example.com" }

  let(:privacy_policy) { create :privacy_policy }

  before do
    privacy_policy.accept!(sit_profile.user)
    privacy_policy.accept!(mentor_profile.user)
    ineligible_ect_profile.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
  end

  scenario "removing participant who didn't start validation" do
    sign_in_as mentor_profile.user
    expect(page).to have_no_content "You do not have access to this service"
    click_on "Sign out"

    sign_in_as sit_profile.user
    visit schools_participants_path(school_cohort.school, school_cohort.cohort)

    within("[data-test='checked']") do
      click_on("Check")
    end

    click_on "Remove #{mentor_profile.user.full_name} from this cohort"
    expect(page)
      .to have_content("Confirm you want to remove #{mentor_profile.user.full_name}")
      .and be_accessible

    page.percy_snapshot("Confirm participant removal")

    expect { click_on "Confirm and remove" }
      .to change { mentor_profile.reload.status }.from("active").to("withdrawn")
      .and change { ect_profile.reload.mentor_profile }.from(mentor_profile).to(nil)

    expect(page)
      .to have_content("#{mentor_profile.user.full_name} has been removed from this cohort")
      .and be_accessible

    page.percy_snapshot("Induction coordinator removing participant")

    click_on "Return to your ECTs and mentors"
    expect(page).to have_no_content mentor_profile.user.full_name
    click_on "Sign out"

    sign_in_as mentor_profile.user
    expect(page).to have_content "You do not have access to this service"
  end

  scenario "removing ineligible participant" do
    sign_in_as sit_profile.user
    visit schools_participants_path(school_cohort.school, school_cohort.cohort)
    within("[data-test='ineligible']") do
      click_on("Check")
    end
    click_on "Remove #{ineligible_user.full_name} from this cohort"

    expect(page).to have_content("Confirm you want to remove #{ineligible_user.full_name}")
    expect { click_on "Confirm and remove" }.to change { ineligible_ect_profile.reload.status }.from("active").to("withdrawn")
    expect(page).to have_content("#{ineligible_user.full_name} has been removed from this cohort")

    click_on "Return to your ECTs and mentor"
    expect(page).to have_no_content ineligible_user.full_name
  end
end
