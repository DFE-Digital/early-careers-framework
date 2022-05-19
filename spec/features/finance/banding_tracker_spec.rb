# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Banding tracker", type: :feature, js: true do
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider).tap do |cpd_lead_provider|
      create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider, revised_target: 65).tap do |call_off_contract|
        band_a, band_b, band_c, band_d = call_off_contract.bands
        band_a.update!(min: nil, max: 20)
        band_b.update!(min: 21,  max: 40)
        band_c.update!(min: 41,  max: 60)
        band_d.update!(min: 61,  max: 65)
      end
    end
  end

  def generate_declarations(state:)
    with_options(cpd_lead_provider: cpd_lead_provider, state: state) do
      create_list(:ect_participant_declaration, 15, declaration_type: "started")
      create_list(:ect_participant_declaration, 20, declaration_type: "retained-1")
      create_list(:ect_participant_declaration, 13, declaration_type: "retained-2")
      create_list(:ect_participant_declaration, 8,  declaration_type: "retained-3")
      create_list(:ect_participant_declaration, 6,  declaration_type: "retained-4")
      create_list(:ect_participant_declaration, 2,  declaration_type: "completed")
    end
  end

  before do
    create(:ecf_schedule)
    generate_declarations(state: :payable)
    generate_declarations(state: :paid)
  end

  xit "displays the distribution of declaration by band, retention type and declaration state" do
    given_i_am_logged_in_as_a_finance_user
    then_the_page_is_accessible

    visit new_finance_banding_tracker_provider_choice_path
    click_on "Continue"

    within "ul.govuk-error-summary__list" do
      expect(page).to have_link("Please select a provider", href: "#finance-banding-tracker-choose-provider-id-field-error")
    end

    choose "Lead Provider"
    click_on "Continue"

    expect(page).to have_css("h2", text: "Banding Tracker")
    expect(page).to have_css("h2", text: cpd_lead_provider.lead_provider.name)

    expect(page).to have_css("tbody tr:nth-child(1)", text: "Paid declarations")

    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(1)", text: "Band A")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(2)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(4)", text: "4")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(5)", text: "8")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(6)", text: "6")
    expect(page).to have_css("tbody tr:nth-child(2) td:nth-child(7)", text: "2")

    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(1)", text: "Band B")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(2)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(3)", text: "11")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(4)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(3) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(1)", text: "Band C")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(2)", text: "11")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(3)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(4) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(1)", text: "Band D")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(2)", text: "4")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(5) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(6)", text: "Payable declarations")

    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(1)", text: "Band A")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(2)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(4)", text: "4")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(5)", text: "8")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(6)", text: "6")
    expect(page).to have_css("tbody tr:nth-child(7) td:nth-child(7)", text: "2")

    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(1)", text: "Band B")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(2)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(3)", text: "11")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(4)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(8) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(1)", text: "Band C")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(2)", text: "11")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(3)", text: "9")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(9) td:nth-child(7)", text: "0")

    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(1)", text: "Band D")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(2)", text: "4")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(3)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(4)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(5)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(6)", text: "0")
    expect(page).to have_css("tbody tr:nth-child(10) td:nth-child(7)", text: "0")
  end
end
