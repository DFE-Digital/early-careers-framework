# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Support Forms: change-participant-lead-provider", type: :feature do
  let(:school) { create(:school) }
  let(:participant_profile) { create(:ect_participant_profile) }

  scenario "User submits a support request" do
    given_a_user_exists
    and_i_am_logged_in_as_user

    visit "/support?subject=change-participant-lead-provider&participant_profile_id=#{participant_profile.id}&school_id=#{school.id}"

    expect(page).to have_text("Support")

    fill_in "support-form-message-field", with: "Test message"

    expect {
      click_button "Confirm"
    }.to change(SupportQuery, :count).by(1)

    expect(SupportQuery.last.as_json).to include(
      "user_id" => @user.id,
      "subject" => "change-participant-lead-provider",
      "message" => "Test message",
      "additional_information" => { "participant_profile_id" => participant_profile.id, "school_id" => school.id },
    )

    expect(page).to have_text("Your support request has been submitted, our support team will get back to you shortly")
  end

  scenario "User submits a support request with invalid IDs in the URL" do
    given_a_user_exists
    and_i_am_logged_in_as_user

    visit "/support?subject=change-participant-lead-provider&participant_profile_id=fake-id&school_id=fake-id"

    expect(page).to have_text("Support")

    fill_in "support-form-message-field", with: "Test message"

    expect {
      click_button "Confirm"
    }.to_not change(SupportQuery, :count)
  end

private

  def given_a_user_exists
    @user = create(:user)
  end

  def and_i_am_logged_in_as_user
    sign_in_as(@user)
  end
end
