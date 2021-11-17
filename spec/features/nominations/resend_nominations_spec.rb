# frozen_string_literal: true

RSpec.feature "Nominations / Resend nomination email", type: :feature, js: true, rutabaga: false do
  let(:local_authority) { create(:local_authority, name: "ABCDEFGHIJK") }

  let(:school) do
    create(:school, urn: "0932244", name: "Test school", address_line1: "102 Bridge Street", postcode: "SE1 1AB")
  end

  before do
    create :school_local_authority, school: school, local_authority: local_authority
  end

  scenario "successful nomination email request" do
    visit resend_email_request_nomination_invite_path

    expect(page).to have_content "Send your school a link to use this service"
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations start page"

    click_on "Continue"

    expect(page).to have_content "What’s your school’s local authority?"
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations choose location page"

    fill_in "What’s your school’s local authority?", with: "ABCD"
    find("li", text: "ABCDEFGHIJK").click
    click_on "Continue"

    expect(page).to have_content "Find your school"
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations choose school page"

    fill_in "Find your school", with: "test"
    find("li", text: "Test school").click
    click_on "Continue"

    expect(page).to have_content "Confirm your details"
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations review page"

    click_on "Change school"
    expect(page).to have_field "What’s your school’s local authority?", with: ""

    fill_in "What’s your school’s local authority?", with: "ABCD"
    find("li", text: "ABCDEFGHIJK").click
    click_on "Continue"
    fill_in "Find your school", with: "test"
    find("li", text: "Test school").click
    click_on "Continue"

    expect(page).to have_content "Confirm your details"
    click_on "Confirm and send"

    expect(page).to have_content "Your school has been sent a link"
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations success page"
  end

  scenario "requesting nomination over the nomination email limit" do
    allow_any_instance_of(InviteSchools).to receive(:reached_limit).with(school).and_return(max: 1, within: 5.minutes)

    visit resend_email_request_nomination_invite_path
    click_on "Continue"

    fill_in "What’s your school’s local authority?", with: "ABCD"
    find("li", text: "ABCDEFGHIJK").click
    click_on "Continue"

    fill_in "Find your school", with: "test"
    find("li", text: "Test school").click
    click_on "Continue"

    expect(page).to have_content("You can only send 1 email per 5 minutes")
    expect(page).to be_accessible
    page.percy_snapshot "Resend nominations limit reached page"
  end

  context "when school is not eligible" do
    let(:school) { create(:school, :ineligible, name: "Test school") }

    scenario "failed nomination email request" do
      visit resend_email_request_nomination_invite_path
      click_on "Continue"

      fill_in "What’s your school’s local authority?", with: "ABCD"
      find("li", text: "ABCDEFGHIJK").click
      click_on "Continue"

      fill_in "Find your school", with: "test"
      find("li", text: "Test school").click
      click_on "Continue"

      expect(page).to have_content "Sorry, teachers cannot serve statutory induction at your school"
      expect(page).to be_accessible
      page.percy_snapshot "Resend nominations not eligible page"
    end
  end
end
