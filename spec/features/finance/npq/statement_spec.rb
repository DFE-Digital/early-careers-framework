# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show NPQ statement", :js do
  let(:cohort)              { Cohort.current || create(:cohort, :current) }
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let(:statement)           { create(:npq_payable_statement, cpd_lead_provider:) }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let(:another_participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let!(:npq_course)         { create(:npq_leadership_course, identifier: "npq-leading-teaching") }
  let!(:contract)           { create(:npq_contract, npq_lead_provider:, cohort:, monthly_service_fee: nil) }

  context "Statement authorise for payment" do
    scenario "successfully authorising" do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_npq_financial_statements_page

      then_i_see("National professional qualifications (NPQs)")

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

      when_i_visit_the_npq_financial_statements_page

      then_i_do_not_see("Authorised for payment at #{statement.marked_as_paid_at.strftime('%-I:%M%P on %-e %b %Y')}".upcase)
    end

    scenario "successfully authorised", perform_jobs: true do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_npq_financial_statements_page

      then_i_see("National professional qualifications (NPQs)")

      and_i_see_authorise_for_payment_button
      when_i_click_the_authorise_for_payment_button

      then_i_see("Check #{statement.name} statement details before authorising for payment")

      when_i_do_all_assurance_checks
      when_i_click_the_authorise_for_payment_button

      then_i_do_not_see("Authorising for payment")

      when_i_visit_the_npq_financial_statements_page

      then_i_see("Authorised for payment at #{Finance::Statement.find(statement.id).marked_as_paid_at.strftime('%-I:%M%P on %-e %b %Y')}".upcase)
    end

    scenario "missing doing assurance checks" do
      given_i_am_logged_in_as_a_finance_user
      and_multiple_declarations_exist

      when_i_visit_the_npq_financial_statements_page

      then_i_see("National professional qualifications (NPQs)")

      and_i_see_authorise_for_payment_button
      when_i_click_the_authorise_for_payment_button

      then_i_see("Check #{statement.name} statement details before authorising for payment")

      when_i_click_the_authorise_for_payment_button

      then_i_do_not_see("Authorising for payment")
      then_i_see("Confirm all necessary assurance checks have been done before authorising this statement for payment")
    end
  end

  def when_i_visit_the_npq_financial_statements_page
    visit("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{statement.id}")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def then_i_do_not_see(string)
    expect(page).not_to have_content(string)
  end

  def and_multiple_declarations_exist
    travel_to statement.deadline_date do
      declaration = create(:npq_participant_declaration, :eligible, cpd_lead_provider:, participant_profile:)
      declaration.statement_line_items.first.update!(statement:, state: declaration.state)

      declaration = create(:npq_participant_declaration, :eligible, cpd_lead_provider:, participant_profile: another_participant_profile)
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
