# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Nominating tutors", :with_default_schedules, :js do
  describe "When nominating an induction tutors with details that are not acceptable" do
    let(:cohort)                  { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: "2021") }
    let(:school)                  { create(:school, name: "CIP School") }
    let(:school_cohort)           { create(:school_cohort, :cip, :with_induction_programme, school:, cohort:) }
    let!(:nomination_email)       { create(:nomination_email, :email_address_already_used_for_another_school, token: "foo-bar-baz") }
    let(:ect_participant_profile) { create(:ect, school_cohort:) }
    let(:different_user)          { create(:user, email: "different-user-type@example.com") }
    let(:mailer)                  { double(SchoolMailer, deliver_later: nil, nomination_confirmation_email: double(ActionMailer::MessageDelivery, deliver_later: true)) }

    before do
      create(:ect, user: different_user)
      allow(SchoolMailer).to receive(:with).with(any_args).and_return(mailer)
    end

    it "shows error messages" do
      visit start_nominate_induction_coordinator_path(token: nomination_email.token)

      choose "Yes"
      click_on "Continue"

      click_on "Continue"

      fill_in "What’s the full name of your induction tutor?", with: "John Wick"
      click_on "Continue"

      fill_in "nominate_induction_tutor_form[email]", with: "john-smith@example.com"
      click_on "Continue"

      expect(page).to have_text("The name you entered does not match our records")

      and_the_page_should_be_accessible

      visit start_nominate_induction_coordinator_path(token: nomination_email.token)

      choose "Yes"
      click_on "Continue"

      click_on "Continue"

      fill_in "What’s the full name of your induction tutor?", with: "John Smith"
      click_on "Continue"

      fill_in "nominate_induction_tutor_form[email]", with: different_user.email
      click_on "Continue"

      expect(page).to have_text("The email address #{different_user.email} is already in use")

      and_the_page_should_be_accessible

      fill_in "nominate_induction_tutor_form[email]", with: "john-smith@example.com"
      click_on "Continue"

      expect(page).to have_summary_row("Name", "John Smith")
      expect(page).to have_summary_row("Email", "john-smith@example.com")

      click_on "Confirm and nominate"

      expect(page).to have_css(".govuk-panel--confirmation", text: "Induction tutor nominated")

      and_the_page_should_be_accessible

      expect(SchoolMailer)
        .to have_received(:with)
        .with(
          sit_profile: User.find_by(email: "john-smith@example.com").induction_coordinator_profile,
          school: nomination_email.school,
          start_url: root_url(
            host: Rails.application.config.domain,
            **UTMService.email(:new_induction_tutor),
          ),
          step_by_step_url: step_by_step_url(
            host: Rails.application.config.domain,
            **UTMService.email(:new_induction_tutor),
          ),
        )
    end
  end
end
