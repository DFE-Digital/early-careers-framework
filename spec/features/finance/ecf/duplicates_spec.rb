require "rails_helper"

RSpec.describe "Duplicate profile tooling", :with_default_schedules, :js do
  let(:ect_participant_profile)   { create(:ect) }
  let(:mentor_participant_profile) { create(:mentor) }
  let(:duplicate_ect_profiles) do
    [
      create(:ect, :withdrawn, :withdrawn_record),
      create(:ect, :withdrawn_record),
      create(:ect, :withdrawn),
    ]
  end
  let(:duplicate_mentor_profiles) do
    [
      create(:mentor, :withdrawn, :withdrawn_record),
      create(:mentor, :withdrawn_record),
      create(:mentor, :withdrawn),
    ]
  end

  before do
    given_i_am_logged_in_as_a_finance_user

    duplicate_ect_profiles.each { |pp| pp.update!(participant_identity: ect_participant_profile.participant_identity) }
    duplicate_mentor_profiles.each { |pp| pp.update!(participant_identity: mentor_participant_profile.participant_identity) }
  end

  it "helps managing duplicate profiles" do
    click_on "ECF Duplicate profiles"

    participant_id = ect_participant_profile.participant_identity.external_identifier
    fill_in "Participant ID", with: participant_id
    click_on "Refine search"

    expect(page.all("tbody tr td:nth-child(1) a").map(&:text)).to all(eq(participant_id))

    select "withdrawn", from: "Training status"
    click_on "Refine search"

    expect(page.all("tbody tr td:nth-child(1)").map(&:text)).to all(eq(participant_id))
    expect(page.all("tbody tr td:nth-child(3)").map(&:text)).to all(eq("withdrawn"))

    select "withdrawn", from: "Induction status"
    click_on "Refine search"

    expect(page.all("tbody tr td:nth-child(1)").map(&:text)).to all(eq(participant_id))
    expect(page.all("tbody tr td:nth-child(2)").map(&:text)).to all(eq("withdrawn"))
    expect(page.all("tbody tr td:nth-child(3)").map(&:text)).to all(eq("withdrawn"))

    save_and_open_page
    within page.find("tbody tr:last-child") do
      click_link "Delete"
    end
    click_link
    save_and_open_page
  end
end
