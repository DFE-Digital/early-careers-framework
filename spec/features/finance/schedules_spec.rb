# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", type: :feature do
  let(:schedule) { create(:ecf_schedule) }
  let(:npq_schedule) { create(:npq_leadership_schedule) }

  scenario "viewing a schedule" do
    given_i_am_logged_in_as_a_finance_user
    and_there_are_schedules
    when_i_click("View payment schedules")
    then_i_see("Schedules")
    and_see_table_with_schedule

    within page.first("table tbody tr", text: /#{schedule.schedule_identifier}/) do
      when_i_click(schedule.schedule_identifier)
    end

    then_i_see("Milestones")
    and_see_table_of_milestones_for_schedule
  end

  scenario "viewing schedules with :disable_npq feature active" do
    given_i_am_logged_in_as_a_finance_user
    and_disable_npq_feature_is_active
    and_there_are_schedules
    when_i_click("View payment schedules")
    then_i_see("Schedules")
    and_i_do_not_see_npq_schedule
  end

  def and_there_are_schedules
    schedule
    npq_schedule
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_see_table_with_schedule
    within(first("table")) do
      expect(page).to have_content(schedule.schedule_identifier)
      expect(page).to have_content(npq_schedule.schedule_identifier)
    end
  end

  def and_i_do_not_see_npq_schedule
    within(first("table")) do
      expect(page).to have_content(schedule.schedule_identifier)
      expect(page).to_not have_content(npq_schedule.schedule_identifier)
    end
  end

  def and_see_table_of_milestones_for_schedule
    within(first("table")) do
      schedule.milestones.each do |milestone|
        expect(page).to have_content(milestone.name)
      end
    end
  end

  def and_disable_npq_feature_is_active
    FeatureFlag.activate(:disable_npq)
  end
end
