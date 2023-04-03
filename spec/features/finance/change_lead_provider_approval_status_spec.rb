# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users NPQ application change lead_provider_approval_status", :with_default_schedules, type: :feature do
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  before do
    given_i_am_logged_in_as_a_finance_user
    when_i_visit_the_finance_participant_drilldown_page
    then_i_see("Participant")
  end

  describe "accepted to pending" do
    let(:npq_application) do
      create(
        :npq_application, :accepted,
        npq_lead_provider:,
        npq_course:
      )
    end
    let!(:user) { npq_application.user }

    scenario "Change status to pending" do
      then_table_value_is(label: "Lead Provider approval status", value: "accepted")
      and_i_click_on("Change to pending")
      then_i_see("Are you sure you want to change the status to pending?")
      and_i_see("Change the status to pending?")
      when_i_choose("Yes")
      and_i_click_on("Continue")
      then_table_value_is(label: "Lead Provider approval status", value: "pending")
    end
  end

  def when_i_visit_the_finance_participant_drilldown_page
    visit("/finance/participants/#{user.id}")
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    then_i_see(string)
  end

  def when_i_choose(text)
    page.choose text
  end

  def then_table_value_is(label:, value:)
    label_field = page.find(".govuk-summary-list__key", text: label)
    expect(label_field).to have_sibling(".govuk-summary-list__value", text: value)
  end
end
