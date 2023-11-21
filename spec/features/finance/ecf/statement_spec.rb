# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show ECF statement", :js do
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
  let!(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:statement) { create(:ecf_payable_statement, cpd_lead_provider:, cohort:) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:schedule) { Finance::Schedule.find_by(schedule_identifier: "ecf-standard-september", cohort:) }

  scenario "Statement includes additional adjustments" do
    given_i_am_logged_in_as_a_finance_user
    and_multiple_additional_adjustments_exist

    when_i_visit_the_ecf_financial_statements_page

    then_i_see("Early career framework (ECF)")
    and_i_see_additional_adjustments_table
    and_i_see_additional_adjustments_total
    and_i_see_save_as_pdf_link
  end

  context "Statement authorise for payment" do
    before { statement.deadline_date + 1.day }

    scenario "successfully authorising" do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_ecf_financial_statements_page

      then_i_see("Early career framework (ECF)")

      and_i_see_authorise_for_payment_button
      when_i_click_the_authorise_for_payment_button

      then_i_see("Check #{statement.name} statement details before authorising for payment")

      when_i_do_all_assurance_checks

      expect {
        when_i_click_the_authorise_for_payment_button
      }.to have_enqueued_job(
        Finance::Statements::MarkAsPaidJob,
      ).with(statement_id: statement.id).on_queue("default")

      then_i_see("Authorising for payment")
      then_i_see("Requested at #{statement.reload.marked_as_paid_at.strftime('%-I:%M%P on %-e %b %Y')}. This may take up to 15 minutes. Refresh to see the updated statement.")

      when_i_visit_the_ecf_financial_statements_page

      then_i_do_not_see("Authorised for payment at #{statement.marked_as_paid_at.in_time_zone('London').strftime('%-I:%M%P on %-e %b %Y')}".upcase)
    end

    scenario "successfully authorised", perform_jobs: true do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_ecf_financial_statements_page

      then_i_see("Early career framework (ECF)")

      and_i_see_authorise_for_payment_button
      when_i_click_the_authorise_for_payment_button

      then_i_see("Check #{statement.name} statement details before authorising for payment")

      when_i_do_all_assurance_checks
      when_i_click_the_authorise_for_payment_button

      then_i_do_not_see("Authorising for payment")

      when_i_visit_the_ecf_financial_statements_page

      then_i_see("Authorised for payment at #{Finance::Statement.find(statement.id).marked_as_paid_at.in_time_zone('London').strftime('%-I:%M%P on %-e %b %Y')}".upcase)
    end

    scenario "missing doing assurance checks" do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_ecf_financial_statements_page

      then_i_see("Early career framework (ECF)")

      and_i_see_authorise_for_payment_button
      when_i_click_the_authorise_for_payment_button

      then_i_see("Check #{statement.name} statement details before authorising for payment")

      when_i_click_the_authorise_for_payment_button

      then_i_do_not_see("Authorising for payment")
      then_i_see("Confirm all necessary assurance checks have been done before authorising this statement for payment")
    end
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{statement.id}")
  end

  def and_multiple_additional_adjustments_exist
    create :adjustment, statement:, payment_type: "Big amount", amount: 999.99
    create :adjustment, statement:, payment_type: "Negative amount", amount: -500.0
    create :adjustment, statement:, payment_type: "Another amount", amount: 300.0
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def then_i_do_not_see(string)
    expect(page).not_to have_content(string)
  end

  def and_i_see_additional_adjustments_table
    expect(page).to have_content("Additional adjustments")
    expect(page).to have_content("Big amount")
    expect(page).to have_content("Negative amount")
    expect(page).to have_content("Another amount")
  end

  def and_i_see_additional_adjustments_total
    expect(page).to have_css(".finance-panel .finance-panel__summary__total-payment-breakdown p:nth-child(5)", text: "Additional adjustments\n£799.99")
  end

  def and_i_see_save_as_pdf_link
    expected_filename = "#{cpd_lead_provider.name} #{statement.name} ECF Statement (#{cohort.start_year} Cohort)"
    expect(page).to have_css("a[data-filename='#{expected_filename}']", text: "Save as PDF")
  end

  def and_multiple_declarations_exist
    milestone = schedule.milestones.find_by(declaration_type: "started")
    travel_to(milestone.milestone_date) do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "started", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end

    milestone = schedule.milestones.find_by(declaration_type: "retained-1")
    travel_to milestone.milestone_date do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "retained-1", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-2").milestone_date do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "retained-2", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-3").milestone_date do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "retained-3", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end

    travel_to schedule.milestones.find_by(declaration_type: "retained-4").milestone_date do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "retained-4", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end

    travel_to schedule.milestones.find_by(declaration_type: "completed").milestone_date do
      declaration = create(:ect_participant_declaration, :payable, declaration_type: "completed", cpd_lead_provider:, cohort:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)
    end
  end

  def and_i_see_authorise_for_payment_button
    expect(page).to have_button("Authorise for payment")
  end

  def when_i_click_the_authorise_for_payment_button
    click_button "Authorise for payment", class: "govuk-button", type: "submit"
  end

  def when_i_do_all_assurance_checks
    check("Yes, I'm ready to authorise this for payment", allow_label_click: true)
  end
end
