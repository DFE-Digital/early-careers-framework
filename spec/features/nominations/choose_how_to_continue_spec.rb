# frozen_string_literal: true

RSpec.feature "Nominations / Choose how to continue", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, :current }
  let!(:school) { create :school }

  before do
    InviteSchools.new.run([school.urn])
    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.first
    visit email.header[:personalisation].unparsed_value[:nomination_link]
  end

  scenario "School has early career teachers for this year" do
    expect(page).to have_content("Do you expect any early career teachers to join your school this academic year?")
    expect(page).to be_accessible

    page.percy_snapshot "Choose how to continue"

    find(:label, text: "Yes").click
    click_on "Continue"

    expect(page).to have_content "Nominate an induction tutor"
  end

  scenario "School does not have any early career teachers this year" do
    find(:label, text: "No").click
    click_on "Continue"

    expect(page)
      .to have_content("Your choice has been saved for 2021/22")
      .and be_accessible

    page.percy_snapshot "Opt out of notifications"
  end

  scenario "School wants to nominate someone for updates" do
    find(:label, text: "We do not know yet").click
    click_on "Continue"

    expect(page).to have_content("Nominate an induction tutor")
  end
end
