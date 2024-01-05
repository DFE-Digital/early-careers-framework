# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Support Forms: change-cohort-induction-programme-choice", type: :feature do
  let(:school) { create(:school) }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:cohort_year) { rand(2020..2030) }

  scenario "User submits a support request" do
    given_a_user_exists
    and_i_am_logged_in_as_user

    visit "/support?subject=change-cohort-induction-programme-choice&cohort_year=#{cohort_year}&school_id=#{school.id}"

    expect(page).to have_text("Support")

    fill_in "support-form-message-field", with: "Test message"

    expect {
      click_button "Send message to support"
    }.to change(SupportQuery, :count).by(1)

    expect(SupportQuery.last.as_json).to include(
      "user_id" => @user.id,
      "subject" => "change-cohort-induction-programme-choice",
      "message" => "Test message",
      "additional_information" => { "cohort_year" => cohort_year.to_s, "school_id" => school.id },
    )

    expect(page).to have_text("Your support request has been submitted")
  end

private

  def given_a_user_exists
    @user = create(:user)
  end

  def and_i_am_logged_in_as_user
    sign_in_as(@user)
  end
end
