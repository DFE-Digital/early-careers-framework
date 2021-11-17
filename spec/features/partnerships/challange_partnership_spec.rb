# frozen_string_literal: true

RSpec.describe "Partnerships / Challenge", type: :feature, js: true do
  let(:school) { create :school, name: "Test school", slug: "111111-test-school" }
  let(:delivery_partner) { FactoryBot.create(:delivery_partner, name: "Test delivery partner") }
  let(:cohort) { create :cohort, start_year: 2021 }
  let(:user) { create :user, :induction_coordinator, schools: [school], email: "test-subject@example.com" }
  let(:lead_provider) { create :lead_provider, name: "Lead Provider" }
  let!(:partnership) { create(:partnership, :in_challenge_window, school: school, cohort: cohort, delivery_partner: delivery_partner, lead_provider: lead_provider) }

  describe "challenging partnership with email link" do
    before do
      PartnershipNotificationService.new.notify(partnership)
    end

    scenario "successful challenge" do
      email = enqueued_emails(to: user.email).first
      visit email.personalisation[:challenge_url]

      expect(page).to have_content "Report that your school has been signed up incorrectly"
      expect(page).to be_accessible
      page.percy_snapshot "challenge options"

      find(:label, text: "This looks like a mistake").click
      click_on "Submit"

      expect(page).to have_content "Your report has been submitted"
      expect(page).to be_accessible
      page.percy_snapshot "challenge success"

      visit email.personalisation[:challenge_url]
      expect(page).to have_content "Someone at Test school has already reported this issue"
      expect(page).to be_accessible
      page.percy_snapshot "already challenged"
    end

    scenario "trying to challenge after the challenge deadline" do
      travel_to partnership.challenge_deadline + 1.hour

      email = enqueued_emails(to: user.email).first
      visit email.personalisation[:challenge_url]

      expect(page).to have_content "This link has expired"
      expect(page).to be_accessible
      page.percy_snapshot "challenge link expired"
    end
  end

  describe "challenging partnership when logged in as FIP induction tutor" do
    let!(:school_cohort) { create :school_cohort, :fip, school: school, cohort: cohort }

    scenario "successful challenge" do
      sign_in_as user
      visit schools_partnerships_path(school, cohort)
      click_on "report that your school has been confirmed incorrectly"

      expect(page).to have_content "Report that your school has been signed up incorrectly"
      find(:label, text: "I do not recognise this training provider").click
      click_on "Submit"

      expect(page).to have_content "Your report has been submitted"

      visit schools_partnerships_path(school, cohort)
      expect(page).to have_content "Signing up with a training provider"
    end
  end

  describe "challenging partnership when logged in as CIP induction tutor" do
    let!(:partnership) do
      create(:partnership,
             challenge_deadline: Time.utc(2099, 1, 1),
             school: school,
             cohort: cohort,
             delivery_partner: delivery_partner,
             pending: true)
    end

    let!(:school_cohort) { create :school_cohort, :cip, school: school, cohort: cohort }

    scenario "successful challenge" do
      sign_in_as user
      visit schools_cohort_path(school, cohort)

      expect(page).to have_content "Test delivery partner, with Lead Provider, has confirmed your school"
      expect(page).to be_accessible
      page.percy_snapshot "partnership notification banner"

      click_on "report it now"

      expect(page).to have_content "Report that your school has been signed up incorrectly"
      find(:label, text: "I do not recognise this training provider").click
      click_on "Submit"

      expect(page).to have_content "Your report has been submitted"

      visit schools_partnerships_path(school, cohort)
      expect(page).to have_content "Signing up with a training provider"
      expect(page).to have_no_content "report it now"
    end
  end
end
