# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Duplicate profile tooling", :js do
  let(:ect_participant_profile)   { create(:ect) }
  let(:mentor_participant_profile) { create(:mentor) }
  let(:duplicate_ect_profiles) do
    [
      create(:ect) do |ect|
        cpd_lead_provider = ect.induction_records.latest.cpd_lead_provider
        create(:ect_participant_declaration, participant_profile: ect, cpd_lead_provider:)
        WithdrawParticipant.new(
          participant_id: ect.user_id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
          reason: "left-teaching-profession",
        ).call
        ect.withdrawn_record!
      end,
      create(:ect) do |ect|
        cpd_lead_provider = ect.induction_records.latest.cpd_lead_provider
        create(:ect_participant_declaration, participant_profile: ect, cpd_lead_provider:)
        ect.withdrawn_record!
      end,
      create(:ect) do |ect|
        cpd_lead_provider = ect.induction_records.latest.cpd_lead_provider
        create(:ect_participant_declaration, participant_profile: ect, cpd_lead_provider:)
        WithdrawParticipant.new(
          participant_id: ect.user_id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
          reason: "left-teaching-profession",
        ).call
      end,
    ]
  end
  let(:duplicate_mentor_profiles) do
    [
      create(:mentor) do |mentor|
        cpd_lead_provider = mentor.induction_records.latest.cpd_lead_provider
        create(:mentor_participant_declaration, participant_profile: mentor, cpd_lead_provider:)
        WithdrawParticipant.new(
          participant_id: mentor.user_id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
          reason: "left-teaching-profession",
        ).call
        mentor.withdrawn_record!
      end,
      create(:mentor) do |mentor|
        cpd_lead_provider = mentor.induction_records.latest.cpd_lead_provider
        create(:mentor_participant_declaration, participant_profile: mentor, cpd_lead_provider:)
        mentor.withdrawn_record!
      end,
      create(:mentor) do |mentor|
        cpd_lead_provider = mentor.induction_records.latest.cpd_lead_provider
        create(:mentor_participant_declaration, participant_profile: mentor, cpd_lead_provider:)
        WithdrawParticipant.new(
          participant_id: mentor.user_id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
          reason: "left-teaching-profession",
        ).call
      end,
    ]
  end

  before do
    given_i_am_logged_in_as_a_finance_user

    duplicate_ect_profiles.each { |pp| pp.update!(participant_identity: ect_participant_profile.participant_identity) }
    duplicate_mentor_profiles.each { |pp| pp.update!(participant_identity: mentor_participant_profile.participant_identity) }
  end

  it "helps managing duplicate profiles" do
    click_on "Search duplicate records"

    expect(page).to have_css("tbody tr td:nth-child(2)", text: ect_participant_profile.user_id)
    expect(page).to have_css("tbody tr td:nth-child(2)", text: mentor_participant_profile.user_id)

    page.find_link("View duplicates", href: finance_ecf_duplicate_path(ect_participant_profile)).click
    within "tbody tr:nth-child(2) td:nth-child(14)" do
      click_on "View details"
    end

    expect(page).to have_css("h1", text: "Compare records")
    expect(page).to have_css("span", text: "Participant ID: #{ect_participant_profile.user_id}")
  end
end
