# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Request access to the service", type: :feature, js: true, rutabaga: false do
  let!(:school) { create(:school, :with_local_authority) }

  scenario "Request access to the service" do
    given_i_am_on_the_start_page
    when_i_click_on_request_access_link
    then_i_am_on_the_send_link_page

    when_i_click_on_continue
    then_i_am_on_the_choose_local_authority_page

    when_i_fill_local_authority_name
    and_i_click_on_continue
    then_i_am_on_the_choose_school_page

    when_i_fill_school_name
    and_i_click_on_continue
    then_i_am_on_the_confirmation_page
    and_i_see_the_school_name
    and_i_see_the_school_redacted_email(school)
  end

  private

  def when_i_click_on_request_access_link
    click_on "request access to the service"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  alias when_i_click_on_continue and_i_click_on_continue

  def then_i_am_on_the_send_link_page
    expect(page).to have_text("Send your school a link to use this service")
  end

  def when_i_fill_local_authority_name
    when_i_fill_in_autocomplete "nomination-request-form-local-authority-id-field", with: school.local_authorities.first.name
  end

  def then_i_am_on_the_choose_local_authority_page
    expect(page).to have_text("What’s your school’s local authority?")
  end

  def when_i_fill_school_name
    when_i_fill_in_autocomplete "nomination-request-form-school-id-field", with: school.name
  end

  def then_i_am_on_the_choose_school_page
    expect(page).to have_text("What’s the name of your school?")
  end

  def then_i_am_on_the_confirmation_page
    expect(page).to have_text("Confirm this is your school")
  end

  def and_i_see_the_school_name
    expect(page).to have_text(school.name)
  end

  def and_i_see_the_school_redacted_email(school)
    redacted_email = EmailDecorator.new(school.primary_contact_email).to_s
    expect(page).to have_text("We'll email an access link to #{redacted_email}")
  end
end
