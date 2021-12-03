# frozen_string_literal: true

RSpec.feature "Nominations / Nominate the tutor", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, :current }
  let!(:school) { create :school, :with_local_authority }

  before do
    InviteSchools.new.run([school.urn])
  end

  scenario "nominating the tutor" do
    visit nomination_emails.first.personalisation[:nomination_link]

    find(:label, text: "Yes").click
    click_on "Continue"

    expect(page).to have_content "Nominate an induction tutor"
    expect(page).to be_accessible
    page.percy_snapshot "Start SIT nomination"

    click_on "Continue"
    expect(page).to have_content "What’s the full name of your induction tutor?"

    click_on "Continue"
    expect(page).to have_content "Enter a full name"

    fill_in "What’s the full name of your induction tutor?", with: "John Doe"
    click_on "Continue"

    expect(page).to have_content "What’s John Doe’s email address?"
    expect(page).to be_accessible
    page.percy_snapshot "Add SIT email"
    click_on "Continue"
    expect(page).to have_content "Enter an email"

    fill_in "What’s John Doe’s email address?", with: "invalid-email@example"
    click_on "Continue"
    expect(page).to have_content "Enter an email address in the correct format, like name@example.com"

    fill_in "What’s John Doe’s email address?", with: "johndoe@example.com"
    click_on "Continue"

    expect(page).to have_content "Check your answers"
    expect(page).to be_accessible
    page.percy_snapshot "Check details"

    click_on "Confirm and nominate"
    expect(page).to have_content "Induction tutor nominated"
    expect(page).to be_accessible
    page.percy_snapshot "Nominate SIT success"

    nomination_confirmation_email = enqueued_emails(
      mailer: SchoolMailer,
      email_name: :nomination_confirmation_email,
    ).first

    expect(nomination_confirmation_email.to).to eq %w[johndoe@example.com]
  end

  scenario "trying to nominate tutor with expired access token" do
    access_token = SchoolAccessToken.last
    travel_to access_token.expires_at + 1.hour

    visit nomination_emails.first.personalisation[:nomination_link]

    expect(page).to have_content "This link has expired"
    expect(page).to be_accessible
    page.percy_snapshot "Nominate a SIT link expired"

    expect {
      click_on "Send new email"
      expect(page).to have_content "Your school has been sent a link"
      expect(page).to be_accessible
    }.to change { nomination_emails.count }.by 1

    expect(page).to have_content "Your school has been sent a link"
    expect(page).to be_accessible

    expect(nomination_emails.last.to).to eq [school.contact_email]
  end

  scenario "trying to nominate tutor for a school that has already nominated one" do
    create :induction_coordinator_profile, schools: [school]
    visit nomination_emails.first.personalisation[:nomination_link]

    expect(page).to have_content "An induction tutor has already been nominated"
    expect(page).to be_accessible
    page.percy_snapshot "SIT already nominated"
  end

  scenario "Nominating an induction tutor with name and email that do not match" do
    create(:induction_coordinator_profile, {
      user: create(:user, full_name: "John Smith", email: "john-smith@example.com"),
      schools: [create(:school)],
    })
    visit nomination_emails.first.personalisation[:nomination_link]
    find(:label, text: "Yes").click
    click_on "Continue"
    expect(page).to have_content "Nominate an induction tutor"

    click_on "Continue"
    fill_in "What’s the full name of your induction tutor?", with: "John Doe"
    click_on "Continue"
    fill_in "What’s John Doe’s email address?", with: "john-smith@example.com"
    click_on "Continue"

    expect(page).to have_content "The name you entered does not match our records"
    expect(page).to be_accessible
    page.percy_snapshot "Different name page"

    click_on "Change the name"
    fill_in "What’s the full name of your induction tutor?", with: "John Doe"
    click_on "Continue"
    fill_in "What’s John Doe’s email address?", with: "johndoeh@example.com"
    click_on "Continue"

    expect(page).to have_content "Check your answers"

    click_on "Confirm and nominate"
    expect(page).to have_content "Induction tutor nominated"
  end

  scenario "Nominating an induction tutor with an email already in use by another school" do
    create :ect_participant_profile, user: create(:user, full_name: "John Doe", email: "johndo2@example.com")
    visit nomination_emails.first.personalisation[:nomination_link]

    find(:label, text: "Yes").click
    click_on "Continue"
    expect(page).to have_content "Nominate an induction tutor"

    click_on "Continue"
    fill_in "What’s the full name of your induction tutor?", with: "John Doe"
    click_on "Continue"
    fill_in "What’s John Doe’s email address?", with: "johndo2@example.com"
    click_on "Continue"

    expect(page).to have_content "The email address is being used by another school"
    expect(page).to be_accessible
    page.percy_snapshot("SIT nomination - Email already in use")

    click_on "Change email address"
    fill_in "What’s the full name of your induction tutor?", with: "John Doe"
    click_on "Continue"
    fill_in "What’s John Doe’s email address?", with: "johndoe@example.com"
    click_on "Continue"

    expect(page).to have_content "Check your answers"
    click_on "Confirm and nominate"
    expect(page).to have_content "Induction tutor nominated"
  end

  def nomination_emails
    enqueued_emails(mailer: SchoolMailer, email_name: :nomination_email)
  end
end
