# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Banding tracker", :with_default_schedules, type: :feature, js: true do
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider, name: "Lead provider name").tap do |cpd_lead_provider|
      create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider, revised_target: 65).tap do |call_off_contract|
        band_a, band_b, band_c, band_d = call_off_contract.bands
        band_a.update!(min: nil, max: 2)
        band_b.update!(min: 3,  max: 5)
        band_c.update!(min: 6,  max: 8)
        band_d.update!(min: 9,  max: 15)
      end
    end
  end
  let(:schedule)           { Finance::Schedule.find_by(schedule_identifier: "ecf-standard-september") }
  let(:next_cohort)        { Cohort.next || create(:cohort, :next) }
  let(:next_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: cpd_lead_provider.lead_provider, cohort: next_cohort) }
  let(:next_cohort_ect)    { create(:ect, school_cohort: next_school_cohort, lead_provider: cpd_lead_provider.lead_provider) }

  def create_output_statement_for(milestone)
    create(:statement, :output_fee, cpd_lead_provider:, deadline_date: milestone.milestone_date)
  end

  def generate_declarations(state:)
    milestone = schedule.milestones.find_by(declaration_type: "started")
    travel_to(milestone.milestone_date) do
      create_list(:ect_participant_declaration, 17, state, declaration_type: "started", cpd_lead_provider:)
    end

    milestone = schedule.milestones.find_by(declaration_type: "retained-1")
    travel_to milestone.milestone_date do
      create_list(:ect_participant_declaration, 5, state, declaration_type: "retained-1", cpd_lead_provider:)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-2").milestone_date do
      create_list(:ect_participant_declaration, 4, state, declaration_type: "retained-2", cpd_lead_provider:)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-3").milestone_date do
      create_list(:ect_participant_declaration, 3, state, declaration_type: "retained-3", cpd_lead_provider:)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-4").milestone_date do
      create_list(:ect_participant_declaration, 1,  state, declaration_type: "retained-4", cpd_lead_provider:)
    end

    travel_to schedule.milestones.find_by(declaration_type: "completed").milestone_date do
      create_list(:ect_participant_declaration, 0,  state, declaration_type: "completed", cpd_lead_provider:)
    end
  end

  before do
    generate_declarations(state: :payable)
    generate_declarations(state: :paid)

    create(:milestone,
           declaration_type: "started",
           milestone_date: Date.new(2022, 12, 22),
           schedule: create(:schedule, schedule_identifier: "ecf-standard-september", name: "ECF September Standard", type: "Finance::Schedule::ECF", cohort: next_cohort))

    travel_to next_cohort_ect.schedule.milestones.find_by(declaration_type: "started").milestone_date do
      create(
        :ect_participant_declaration,
        participant_profile: next_cohort_ect,
        cpd_lead_provider:,
      )
    end
  end

  it "displays the distribution of declaration by band, retention type and declaration state" do
    given_i_sign_in_as_a_finance_user
    then_the_page_is_accessible

    visit new_finance_banding_tracker_provider_choice_path
    click_on "Continue"

    within "ul.govuk-error-summary__list" do
      expect(page).to have_link("Please select a provider", href: "#finance-banding-tracker-choose-provider-id-field-error")
    end

    choose "Lead provider name"
    click_on "Continue"

    expect(page).to have_css("h2", text: "Banding Tracker")
    expect(page).to have_css("h2", text: cpd_lead_provider.lead_provider.name)

    expect(page).to have_css("tbody tr:nth-child(1)", text: "Paid declarations")

    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(1)", text: "Band A")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(2)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(3)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(4)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(5)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(6)", text: "1")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(1)", text: "Band B")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(2)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(3)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(4)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(5)", text: "1")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(1)", text: "Band C")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(2)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(1)", text: "Band D")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(2)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(6)", text: "Payable declarations")

    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(1)", text: "Band A")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(2)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(3)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(4)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(5)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(6)", text: "1")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(1)", text: "Band B")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(2)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(3)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(4)", text: "2")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(5)", text: "1")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(1)", text: "Band C")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(2)", text: "3")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(1)", text: "Band D")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(2)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(7)", text: "0")
  end
end
