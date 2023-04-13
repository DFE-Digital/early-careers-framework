# frozen_string_literal: true

RSpec.describe "SIT removing participants from the cohort", js: true, with_feature_flags: { eligibility_notifications: "active", cohortless_dashboard: "active" } do
  let(:sit_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }
  let(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
  let(:mentor_user) { create :user, :teacher, full_name: "John Doe", email: "john-doe@example.com" }
  let!(:mentor_profile) { create(:mentor_participant_profile, request_for_details_sent_at: Date.new(2021, 9, 9), school_cohort:, teacher_profile: mentor_user.teacher_profile) }
  let(:ect_user) { create :user, :teacher, full_name: "John Smith", email: "john-smith@example.com" }
  let!(:ect_profile) { create(:ect_participant_profile, school_cohort:, mentor_profile:, teacher_profile: ect_user.teacher_profile) }
  let!(:ineligible_ect_profile) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:, teacher_profile: ineligible_user.teacher_profile) }
  let(:ineligible_user) { create :user, :teacher, full_name: "Kate Edwards", email: "kate-edwards@example.com" }

  let(:privacy_policy) { create :privacy_policy }

  before do
    Induction::SetCohortInductionProgramme.call(school_cohort:, programme_choice: "full_induction_programme")
    Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: school_cohort.default_induction_programme)
    Induction::Enrol.call(participant_profile: ect_profile, induction_programme: school_cohort.default_induction_programme, mentor_profile:)
    Induction::Enrol.call(participant_profile: ineligible_ect_profile, induction_programme: school_cohort.default_induction_programme)
    privacy_policy.accept!(sit_profile.user)
    privacy_policy.accept!(mentor_profile.user)
    ineligible_ect_profile.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
  end

  scenario "removing participant who didn't start validation" do
    sign_in_as mentor_profile.user
    expect(page).to have_no_content "You do not have access to this service"
    click_on "Sign out"

    sign_in_as sit_profile.user
    visit school_participants_path(school_cohort.school)
    click_on mentor_profile.user.full_name
    click_on "Remove #{mentor_profile.user.full_name}"

    expect(page)
      .to have_content("Confirm you want to remove #{mentor_profile.user.full_name}")
      .and be_accessible
    expect { click_on "Confirm and remove" }
      .to change { mentor_profile.reload.status }.from("active").to("withdrawn")
      .and change { ect_profile.reload.mentor_profile }.from(mentor_profile).to(nil)
    expect(page)
      .to have_content("#{mentor_profile.user.full_name} has been removed from this cohort")
      .and be_accessible

    click_on "Return to manage mentors and ECTs"
    expect(page).to have_no_content mentor_profile.user.full_name
    click_on "Sign out"

    sign_in_as mentor_profile.user
    expect(page).to have_content "You do not have access to this service"
  end

  scenario "removing ineligible participant" do
    sign_in_as sit_profile.user
    visit school_participants_path(school_cohort.school)

    click_on ineligible_user.full_name
    click_on "Remove #{ineligible_user.full_name}"

    expect(page).to have_content("Confirm you want to remove #{ineligible_user.full_name}")
    expect { click_on "Confirm and remove" }.to change { ineligible_ect_profile.reload.status }.from("active").to("withdrawn")
    expect(page).to have_content("#{ineligible_user.full_name} has been removed from this cohort")

    click_on "Return to manage mentors and ECTs"
    expect(page).to have_no_content ineligible_user.full_name
  end
end
