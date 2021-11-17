# frozen_string_literal: true

RSpec.feature "Nominations / Nominate the tutor", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, :current }
  let!(:school) { create :school, :with_local_authority }

  before do
    InviteSchools.new.run([school.urn])
  end

  scenario "nominating the tutor" do
    visit nomination_emails.first.personalisation[:nomination_link]

    find(:label, text: "Yes, (nominate someone to set up your induction for 2021/22)").click
    click_on "Continue"

    expect(page).to have_content "Nominate an induction tutor"
    expect(page).to be_accessible

    click_on "Start"
    fill_in "Full name", with: "John Smith"
    fill_in "Work email address", with: "john-smith@example.com"
    click_on "Confirm"

    expect(page).to have_content "Induction tutor nominated"
    expect(page).to be_accessible
    page.percy_snapshot "Induction lead nominated"

    nomination_confirmation_email = enqueued_emails(
      mailer: SchoolMailer,
      email_name: :nomination_confirmation_email,
    ).first

    expect(nomination_confirmation_email.to).to eq %w[john-smith@example.com]
  end

  scenario "trying to nominate tutor with expired access token" do
    access_token = SchoolAccessToken.last
    travel_to access_token.expires_at + 1.hour

    visit nomination_emails.first.personalisation[:nomination_link]

    expect(page).to have_content "This link has expired"
    expect(page).to be_accessible
    page.percy_snapshot "Start nominations with invalid token page"

    expect {
      click_on "Resend email"
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
    page.percy_snapshot "Start nominations already nominated page"
  end

  scenario "trying to nominate existing user with invalid data" do
    john_smith = create :user, full_name: "John Smith", email: "john-smith@example.com"
    create :induction_coordinator_profile, schools: [create(:school)], user: john_smith

    different_user = create :user, email: "different-user-type@example.com"
    teacher_profile = create :teacher_profile, user: different_user
    create :participant_profile, :ect, teacher_profile: teacher_profile

    visit nomination_emails.first.personalisation[:nomination_link]

    find(:label, text: "Yes, (nominate someone to set up your induction for 2021/22)").click
    click_on "Continue"
    click_on "Start"

    fill_in "Full name", with: "John Wick"
    fill_in "Work email address", with: "john-smith@example.com"
    click_on "Confirm"

    expect(page).to have_content "The name you entered does not match our records"
    expect(page).to be_accessible
    page.percy_snapshot "Start nominations name different"

    click_on "Change the name"
    fill_in "Full name", with: "John Smith"
    fill_in "Work email address", with: "different-user-type@example.com"
    click_on "Confirm"

    expect(page).to have_content "The email you entered is used by another school"
    expect(page).to be_accessible
    page.percy_snapshot "Start nominations email already used"

    click_on "Change email address"
    fill_in "Full name", with: "John Smith"
    fill_in "Work email address", with: "john-smith@example.com"
    click_on "Confirm"

    expect(page).to have_content "Induction tutor nominated"
  end

  def nomination_emails
    enqueued_emails(mailer: SchoolMailer, email_name: :nomination_email)
  end
end
