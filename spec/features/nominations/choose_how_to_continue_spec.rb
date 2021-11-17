# frozen_string_literal: true

RSpec.feature "Nominations / Choose how to continue", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, :current }
  let!(:school) { create :school }

  before do
    InviteSchools.new.run([school.urn])

    email = enqueued_emails(mailer: SchoolMailer).first
    visit email.personalisation[:nomination_link]
  end

  scenario "School has early career teachers for this year" do
    expect(page).to have_content("Do you expect to have any early career teachers at #{school.name} this year?")
    expect(page).to be_accessible

    page.percy_snapshot "Choose how to continue"

    find(:label, text: "Yes, (nominate someone to set up your induction for 2021/22)").click
    click_on "Continue"

    expect(page).to have_content "Nominate an induction tutor"
  end

  scenario "School does not have any early career teachers this year" do
    find(:label, text: "No, (opt out of updates about this service until the next academic year)").click
    click_on "Continue"

    expect(page)
      .to have_content("Your choice has been saved for 2021/22")
      .and be_accessible

    page.percy_snapshot "Opt out of notifications"
  end

  scenario "School wants to nominate someone for updates" do
    find(:label, text: "I don’t know, (nominate someone to receive updates)").click
    click_on "Continue"

    expect(page).to have_content("Nominate an induction tutor")
  end
end
