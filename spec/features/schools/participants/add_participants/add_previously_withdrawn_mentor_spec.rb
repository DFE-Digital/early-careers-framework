# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding previously withdrawn Mentor", type: :feature, js: true do
  let(:previous_cohort) { create(:cohort, :previous) }
  let!(:cohort) { Cohort.current || create(:cohort, :current) }
  let!(:school) { create(:school, name: "Fip School") }
  let!(:appropriate_body) { create :appropriate_body_national_organisation }
  let!(:previous_school_cohort) do
    create_previous_school_cohort(school)
  end
  let!(:previous_school_cohort_different_school) do
    create_previous_school_cohort(create(:school, name: "Fip School"))
  end
  let!(:school_cohort) { create(:school_cohort, school:, cohort:, induction_programme_choice: "full_induction_programme", appropriate_body:) }
  let(:lead_provider) { create(:lead_provider, name: "Big Provider Ltd") }
  let(:delivery_partner) { create(:delivery_partner, name: "Amazing Delivery Team") }
  let!(:partnership) do
    create(:partnership,
           school:,
           lead_provider:,
           delivery_partner:,
           cohort:,
           challenge_deadline: 2.weeks.ago)
  end
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
    school_cohort.update!(default_induction_programme: induction_programme)
    induction_programme
  end
  let!(:user) { create(:user, full_name: "Induction tutor") }
  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end
  let!(:induction_coordinator) do
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user:)
    PrivacyPolicy.current.accept!(user)
    induction_coordinator_profile
  end
  let!(:schedule) { create(:ecf_schedule) }

  let(:induction_start_date) { 1.month.ago }

  let(:creation_date_for_withdrawn_record) { Date.new(previous_cohort.start_year, 1, 1) }

  let(:ect_full_name) { "George Mentor" }
  let(:ect_trn) { "1234456" }
  let(:ect_dob) { "1998-11-22" }
  let(:ect_email) { "ect@email.gov.uk" }

  before do
    disable_cohort_setup_check
    school_cohort.update!(default_induction_programme: induction_programme)
  end

  scenario "Adding a Mentor back to the school it was withdrawn from" do
    participant_profile = add_and_remove_participant_from_school_cohort(previous_school_cohort)
    the_participant_profile_is_set_up_as_withdrawn_correctly(participant_profile, previous_school_cohort)

    outside_auto_assignment_window do
      expect {
        sign_in

        when_i_go_to_add_new_mentor_page
        and_i_go_through_the_who_do_you_want_to_add_page
        and_i_go_through_the_what_we_need_from_you_page

        and_i_fill_in_all_info
        then_i_am_taken_to_mentor_start_training_page

        when_i_choose_summer_term_this_cohort
        when_i_click_on_continue
        then_i_am_taken_to_choose_mentor_partnership_page

        when_i_choose_current_providers
        when_i_click_on_continue
        then_i_am_taken_to_the_confirmation_page
        and_i_see_the_correct_details(joint_provider_details: true)

        when_i_check_the_mentor_details
        and_i_see_the_correct_details

        and_the_participant_profile_is_set_up_correctly(participant_profile)
      }.to_not change { ParticipantProfile.count }
    end
  end

  scenario "Adding a Mentor without validation data back to the school it was withdrawn from" do
    participant_profile = add_and_remove_participant_from_school_cohort(previous_school_cohort)
    participant_profile.teacher_profile.update!(trn: nil)
    the_participant_profile_is_set_up_as_withdrawn_correctly(
      participant_profile,
      previous_school_cohort,
      expected_trn: nil,
    )

    outside_auto_assignment_window do
      expect {
        sign_in

        when_i_go_to_add_new_mentor_page
        and_i_go_through_the_who_do_you_want_to_add_page
        and_i_go_through_the_what_we_need_from_you_page

        and_i_fill_in_all_info
        then_i_am_taken_to_mentor_start_training_page

        when_i_choose_summer_term_this_cohort
        when_i_click_on_continue
        then_i_am_taken_to_choose_mentor_partnership_page

        when_i_choose_current_providers
        when_i_click_on_continue
        then_i_am_taken_to_the_confirmation_page
        and_i_see_the_correct_details(joint_provider_details: true)

        when_i_check_the_mentor_details
        and_i_see_the_correct_details

        and_the_participant_profile_is_set_up_correctly(participant_profile)
      }.to_not change { ParticipantProfile.count }
    end
  end

  scenario "Adding a Mentor back to the school it was withdrawn from with a different email" do
    participant_profile = add_and_remove_participant_from_school_cohort(previous_school_cohort)
    the_participant_profile_is_set_up_as_withdrawn_correctly(participant_profile, previous_school_cohort)

    outside_auto_assignment_window do
      expect {
        new_email = "another_#{ect_email}"

        sign_in

        when_i_go_to_add_new_mentor_page
        and_i_go_through_the_who_do_you_want_to_add_page
        and_i_go_through_the_what_we_need_from_you_page

        and_i_fill_in_all_info(email: new_email)
        then_i_am_taken_to_mentor_start_training_page

        when_i_choose_summer_term_this_cohort
        when_i_click_on_continue
        then_i_am_taken_to_choose_mentor_partnership_page

        when_i_choose_current_providers
        when_i_click_on_continue
        then_i_am_taken_to_the_confirmation_page
        and_i_see_the_correct_details(joint_provider_details: true, expected_email: new_email)

        when_i_check_the_mentor_details
        and_i_see_the_correct_details(expected_email: new_email)

        and_the_participant_profile_is_set_up_correctly(participant_profile)
      }.to_not change { ParticipantProfile.count }
    end
  end

  scenario "Adding a Mentor to a school different to the one it was withdrawn from" do
    participant_profile = add_and_remove_participant_from_school_cohort(previous_school_cohort_different_school)
    the_participant_profile_is_set_up_as_withdrawn_correctly(participant_profile, previous_school_cohort_different_school)

    outside_auto_assignment_window do
      expect {
        sign_in

        when_i_go_to_add_new_mentor_page
        and_i_go_through_the_who_do_you_want_to_add_page
        and_i_go_through_the_what_we_need_from_you_page

        and_i_fill_in_all_info
        then_i_am_taken_to_mentor_start_training_page

        when_i_choose_summer_term_this_cohort
        when_i_click_on_continue
        then_i_am_taken_to_choose_mentor_partnership_page

        when_i_choose_current_providers
        when_i_click_on_continue
        then_i_am_taken_to_the_confirmation_page
        and_i_see_the_correct_details(joint_provider_details: true)

        when_i_check_the_mentor_details
        and_i_see_the_correct_details

        and_the_participant_profile_is_set_up_correctly(participant_profile)
      }.to_not change { ParticipantProfile.count }
    end
  end

private

  def create_previous_school_cohort(school_for_cohort)
    create(
      :school_cohort,
      school: school_for_cohort,
      cohort: previous_cohort,
      induction_programme_choice: "full_induction_programme",
      appropriate_body:,
    ).tap do |school_cohort|
      induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
      school_cohort.update! default_induction_programme: induction_programme
    end
  end

  def add_and_remove_participant_from_school_cohort(school_cohort)
    participant_profile = nil
    travel_to(creation_date_for_withdrawn_record) do
      participant_profile = add_participant_to_school(full_name: ect_full_name,
                                                      email: ect_email,
                                                      school_cohort:)
      withdraw_participant(participant_profile:)
    end

    participant_profile
  end

  def add_participant_to_school(full_name:, email:, school_cohort:)
    Mentors::Create.call(
      full_name:,
      email:,
      school_cohort:,
      start_date: Time.current,
    ).tap do |participant_profile|
      participant_profile.teacher_profile.update!(trn: ect_trn)
    end
  end

  def withdraw_participant(participant_profile:)
    participant_profile.update!(status: :withdrawn)
    participant_profile.reload.latest_induction_record.withdrawing!
    participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)

    participant_profile.mentee_profiles.each do |mentee_profile|
      Induction::ChangeInductionRecord.call(
        induction_record: mentee_profile.latest_induction_record,
        changes: {
          mentor_profile_id: nil,
        },
      )
    end
  end

  def sign_in
    sign_in_as user
  end

  def when_i_go_to_add_new_ect_page
    click_on "Early Career Teacher"
    click_on "Add ECT"
  end

  def when_i_go_to_add_new_mentor_page
    click_on "Mentors"
    click_on "Add Mentor"
  end

  def and_i_go_through_the_who_do_you_want_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
    choose "Mentor"
    click_on "Continue"
  end

  def and_i_go_through_the_what_we_need_from_you_page
    expect(page).to have_selector("h1", text: "What we need to know about this mentor")
    click_on "Continue"
  end

  def and_i_fill_in_all_info(email: ect_email)
    stubbed_dqt_check_response = DQTRecordCheck::CheckResult.new(
      valid_dqt_response,
      true,
      true,
      true,
      false,
      3,
    )

    allow(DQTRecordCheck).to receive(:call).and_return(stubbed_dqt_check_response)

    fill_in "add_participant_wizard[full_name]", with: ect_full_name
    click_on "Continue"
    fill_in "add_participant_wizard[trn]", with: ect_trn
    click_on "Continue"
    fill_in_date("What’s George Mentor’s date of birth?", with: ect_dob)
    click_on "Continue"
    fill_in "add_participant_wizard[email]", with: email
    click_on "Continue"
  end

  def valid_dqt_response
    DQTRecordPresenter.new({
      "name" => "George Mentor",
      "trn" => ect_trn,
      "state_name" => "Active",
      "dob" => Date.new(1998, 11, 22),
      "qualified_teacher_status" => { "qts_date" => 1.year.ago },
      "induction_start_date" => induction_start_date.to_date,
      "induction" => {
        "periods" => [{ "startDate" => induction_start_date }],
        "status" => "Active",
      },
    })
  end

  def then_i_am_taken_to_mentor_start_training_page
    expect(page).to have_selector("h1", text: "When will George Mentor start their mentor training?")
  end

  def when_i_choose_summer_term_this_cohort
    choose "Summer term #{Cohort.current.start_year + 1}"
  end

  def then_i_am_taken_to_the_confirm_appropriate_body_page
    expect(page).to have_content("Is this the appropriate body for George Mentor’s induction?")
  end

  def then_i_am_taken_to_choose_mentor_partnership_page
    expect(page).to have_selector("h1", text: "Who will George Mentor do their mentor training with?")
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(page).to have_content("Check your answers")
  end

  def and_i_see_the_correct_details(joint_provider_details: false, expected_email: ect_email)
    expect(page).to have_summary_row("Name", ect_full_name)
    expect(page).to have_summary_row("TRN", ect_trn)
    expect(page).to have_summary_row("Date of birth", ect_dob.to_date.to_fs(:govuk))
    expect(page).to have_summary_row("Email address", expected_email)

    if joint_provider_details
      expect(page).to have_summary_row("Training with", [lead_provider.name, delivery_partner.name].join("\n"))
    else
      expect(page).to have_summary_row("Lead provider", lead_provider.name)
      expect(page).to have_summary_row("Delivery partner", delivery_partner.name)
    end
  end

  def then_i_am_taken_to_the_email_already_taken_page
    expect(page).to have_content("This email is being used by someone at another school")
    expect(page).to have_content("Contact them directly to check whether they need to be transferred to your school")
  end

  def the_participant_profile_is_set_up_as_withdrawn_correctly(participant_profile, expected_school_cohort, expected_trn: ect_trn)
    participant_profile.reload
    expected_cohort = expected_school_cohort.cohort
    expect([
      participant_profile.status,
      participant_profile.training_status,
      participant_profile.latest_induction_record.reload.induction_status,
      participant_profile.cohort.start_year,
      participant_profile.schedule.id,
      participant_profile.school_cohort_id,
      participant_profile.mentor_profile_id,
      participant_profile.induction_start_date,
      participant_profile.teacher_profile.trn,
    ]).to match [
      "withdrawn",
      "active",
      "withdrawn",
      expected_cohort.start_year,
      Finance::Schedule::ECF.default_for(cohort: expected_cohort).id,
      expected_school_cohort.id,
      nil,
      nil,
      expected_trn,
    ]
  end

  def and_the_participant_profile_is_set_up_correctly(participant_profile)
    participant_profile.reload
    expect([
      participant_profile.status,
      participant_profile.training_status,
      participant_profile.latest_induction_record.reload.induction_status,
      participant_profile.cohort.start_year,
      participant_profile.schedule.id,
      participant_profile.school_cohort_id,
      participant_profile.mentor_profile_id,
      participant_profile.teacher_profile.trn,
    ]).to match [
      "active",
      "active",
      "active",
      cohort.start_year,
      Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort).id,
      school_cohort.id,
      nil,
      ect_trn,
    ]
    expect(participant_profile.induction_start_date).to_not be_nil
  end

  def when_i_check_the_mentor_details
    click_on "Confirm and add"
    click_on "View your mentors"
    click_on "George Mentor"
  end

  def when_i_click_on_confirm
    click_on "Confirm"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  def when_i_choose_current_providers
    choose option: "current_providers"
  end
end
