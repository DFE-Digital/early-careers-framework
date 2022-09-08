# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin viewing participants", js: true, rutabaga: false do
  scenario "Admin can see all current and transferring in/out participants" do
    given_there_is_a_school_with_current_and_transferring_participants
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_participants_page
    then_i_should_see_all_the_current_and_transferring_participants
    and_the_page_should_be_accessible
  end

private

  def given_there_is_a_school_with_current_and_transferring_participants
    @school = create(:school, name: "Test school")
    cohort = create(:cohort, start_year: 2021)
    school_cohort = create(:school_cohort, :fip, school: @school, cohort:)

    charlie = create(:ect_participant_profile, school_cohort:, user: create(:user, full_name: "Charlie Current"))
    theresa = create(:ect_participant_profile, user: create(:user, full_name: "Theresa Transfer-In"))
    linda = create(:ect_participant_profile, school_cohort:, user: create(:user, full_name: "Linda Leaving"))

    programme = create(:induction_programme, :fip, school_cohort:)
    school_cohort.update!(default_induction_programme: programme)

    programme2 = create(:induction_programme, :fip, school_cohort: theresa.school_cohort)
    induction_record = Induction::Enrol.call(participant_profile: theresa, induction_programme: programme2, start_date: Date.new(2021, 9, 1))
    induction_record.leaving!(2.months.from_now)
    Induction::Enrol.call(participant_profile: charlie, induction_programme: programme, start_date: Date.new(2021, 12, 1))
    Induction::Enrol.call(participant_profile: linda, induction_programme: programme, start_date: Date.new(2021, 9, 1))
    Induction::Enrol.call(participant_profile: theresa, induction_programme: programme, start_date: induction_record.end_date, school_transfer: true)
    linda.current_induction_record.leaving!(1.week.from_now)
  end

  def the_school_participants_page
    admin_school_participants_path(school_id: @school.slug)
  end

  def then_i_should_see_all_the_current_and_transferring_participants
    expect(page).to have_content "Charlie Current"
    expect(page).to have_content "Theresa Transfer-In"
    expect(page).to have_content "Linda Leaving"
  end
end
