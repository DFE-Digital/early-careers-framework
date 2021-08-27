# frozen_string_literal: true

RSpec.describe "STI removing participants from the cohort", js: true, with_feature_flags: { induction_tutor_manage_participants: "active" } do
  let(:sti_profile) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }
  let(:school_cohort) { create(:school_cohort) }
  let!(:participant_profile) { create(:participant_profile, :ecf, school_cohort: school_cohort) }
  let(:privacy_policy) { create :privacy_policy }

  before do
    privacy_policy.accept!(sti_profile.user)
    privacy_policy.accept!(participant_profile.user)
  end

  scenario "removing participant who didn't start validation" do
    sign_in_as participant_profile.user
    expect(page).to have_no_content "You do not have access to this service"
    click_on "Sign out"

    sign_in_as sti_profile.user
    visit schools_participants_path(school_cohort.school, school_cohort.cohort)
    click_on participant_profile.user.full_name
    click_on "Remove #{participant_profile.user.full_name} from this cohort"

    expect { click_on "Confirm and remove" }.to change { participant_profile.reload.status }.from("active").to("withdrawn")
    expect(page).to have_content "#{participant_profile.user.full_name} has been removed from this cohort"

    click_on "Return to your ECTs and mentor"
    expect(page).to have_no_content participant_profile.user.full_name
    click_on "Sign out"

    sign_in_as participant_profile.user
    expect(page).to have_content "You do not have access to this service"
  end
end
