# frozen_string_literal: true

RSpec.describe "STI removing participants from the cohort", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  let(:sti_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }
  let(:school_cohort) { create(:school_cohort) }
  let!(:mentor_profile) { create(:participant_profile, :mentor, school_cohort: school_cohort, user: create(:user, full_name: "John Doe", email: "john-doe@example.com")) }
  let!(:ect_profile) { create(:participant_profile, :ect, school_cohort: school_cohort, mentor_profile: mentor_profile, user: create(:user, full_name: "John Smith", email: "john-smith@example.com")) }
  let(:privacy_policy) { create :privacy_policy }

  before do
    privacy_policy.accept!(sti_profile.user)
    privacy_policy.accept!(mentor_profile.user)
  end

  scenario "removing participant who didn't start validation" do
    sign_in_as mentor_profile.user
    expect(page).to have_no_content "You do not have access to this service"
    click_on "Sign out"

    sign_in_as sti_profile.user
    visit schools_participants_path(school_cohort.school, school_cohort.cohort)
    click_on mentor_profile.user.full_name
    click_on "Remove #{mentor_profile.user.full_name} from this cohort"

    expect { click_on "Confirm and remove" }
      .to change { mentor_profile.reload.status }.from("active").to("withdrawn")
      .and change { ect_profile.reload.mentor_profile }.from(mentor_profile).to(nil)
    expect(page).to have_content "#{mentor_profile.user.full_name} has been removed from this cohort"
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Induction coordinator removing participant")

    click_on "Return to your ECTs and mentor"
    expect(page).to have_no_content mentor_profile.user.full_name
    click_on "Sign out"

    sign_in_as mentor_profile.user
    expect(page).to have_content "You do not have access to this service"
  end
end
