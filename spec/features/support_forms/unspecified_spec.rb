# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Support Forms: Unspecified", type: :feature do
  scenario "User submits a support request" do
    given_a_user_exists
    and_i_am_logged_in_as_user

    visit "/support"

    expect(page).to have_text("Support")

    fill_in "support-form-message-field", with: "Test message"

    expect {
      click_button "Confirm"
    }.to change(SupportQuery, :count).by(1)

    expect(SupportQuery.last.as_json).to include(
      "user_id" => @user.id,
      "subject" => "unspecified",
      "message" => "Test message",
      "additional_information" => {},
    )

    expect(page).to have_text("Your support request has been submitted, our support team will get back to you shortly")
  end

private

  def given_a_user_exists
    @user = create(:user)
  end

  def and_i_am_logged_in_as_user
    sign_in_as(@user)
  end
end
