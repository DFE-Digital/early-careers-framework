# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring a withdrawn participant", type: :feature, js: true do
  before do
    allow_participant_transfer_mailers
    set_participant_data
    set_dqt_validation_result
    given_there_are_two_schools_that_have_chosen_fip_for_current_cohort_and_partnered
    and_there_is_a_withdrawn_ect_who_will_be_transferring
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_selected_my_cohort_tab
    when_i_click_to_view_ects_and_mentors
    then_i_am_taken_to_manage_mentors_and_ects_page
  end

  scenario "SIT can transfer a withdrawn participant" do
    when_i_click_to_add_a_new_ect_or_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_the_ect_option
    click_on "Continue"
    then_i_should_be_on_what_we_need_page

    click_on "Continue"
    then_i_should_be_on_full_name_page

    when_i_update_the_name_with("Sally Teacher")
    click_on "Continue"
    then_i_should_be_on_trn_page

    when_i_add_a_valid_trn
    click_on "Continue"
    then_i_should_be_on_the_date_of_birth_page

    when_i_add_a_valid_date_of_birth
    click_on "Continue"

    then_i_should_be_on_the_confirm_transfer_page
    click_on "Confirm"

    then_i_should_be_on_the_teacher_start_date_page
    when_i_add_a_valid_start_date
    click_on "Continue"

    then_i_should_be_on_the_add_email_page
    when_i_update_the_email_with("sally-teacher@example.com")
    click_on "Continue"

    then_i_should_be_on_the_select_mentor_page
    and_it_should_list_the_schools_mentors
    when_i_assign_a_mentor
    click_on "Continue"
    then_i_should_be_taken_to_the_schools_current_programme_page

    when_i_select @lead_provider.name
    click_on "Continue"
    then_i_should_be_taken_to_the_check_your_answers_page

    click_on "Confirm and add"
    then_i_should_be_on_the_complete_page

    and_the_participant_should_be_notified
    and_the_schools_current_provider_is_notified

    click_on "View your ECTs and mentors"
    then_i_am_taken_to_manage_mentors_and_ects_page
  end

  # given

  def given_there_are_two_schools_that_have_chosen_fip_for_current_cohort_and_partnered
    @cohort = Cohort.current
    @school_one = create(:school, name: "Fip School 1")
    @school_two = create(:school, name: "Fip School 2")
    create(:school_cohort, :fip, :with_induction_programme, school: @school_one, cohort: Cohort.next || create(:cohort, :next))
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    @school_cohort_one = create(:school_cohort, :fip, :with_induction_programme, school: @school_one, cohort: @cohort, lead_provider: @lead_provider, delivery_partner: @delivery_partner)

    @lead_provider_two = create(:lead_provider, name: "Massive Provider Ltd")
    @other_delivery_partner = create(:delivery_partner, name: "Fantastic Delivery Team")
    @school_cohort_two = create(:school_cohort, :fip, :with_induction_programme, school: @school_two, cohort: @cohort, lead_provider: @lead_provider_two, delivery_partner: @other_delivery_partner)

    @lead_provider_profile = create(:lead_provider_profile, lead_provider: @lead_provider)
    @mentor = create(:mentor, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)

    @induction_programme_one = @school_cohort_one.default_induction_programme
    @induction_programme_two = @school_cohort_two.default_induction_programme
  end

  # when

  def when_i_click_to_view_ects_and_mentors
    click_on("Manage mentors and ECTs")
  end

  def when_i_click_to_add_a_new_ect_or_mentor
    click_on "Add ECT or mentor"
  end

  def when_i_select_the_ect_option
    choose("ECT", allow_label_click: true)
  end

  def when_i_update_the_name_with(name)
    fill_in "What’s this ECT’s full name?", with: name
  end

  def when_i_update_the_email_with(email)
    fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: email
  end

  def when_i_add_a_valid_trn
    fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)", with: @participant_data[:trn]
  end

  def when_i_add_a_valid_date_of_birth
    legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

    fill_in_date(legend, with: "1990-10-24")
  end

  def when_i_add_a_valid_start_date
    legend = "When is #{@participant_data[:full_name]} moving to your school?"

    fill_in_date(legend, with: "2023-10-24")
  end

  def when_i_assign_a_mentor
    choose(@mentor.user.full_name)
  end

  def when_i_select(option)
    choose(option)
  end

  # then

  def then_i_am_taken_to_manage_mentors_and_ects_page
    expect(page).to have_selector("h1", text: "Manage mentors and ECTs")
    expect(page).to have_text("Add ECT or mentor")
  end

  def then_i_am_taken_to_a_dashboard_page
    expect(page).to have_selector("h1", text: "Manage your training")
  end

  def then_i_should_be_on_what_we_need_page
    expect(page).to have_selector("h1", text: "What we need to know about this ECT")
  end

  def then_i_should_be_on_full_name_page
    expect(page).to have_selector("h1", text: "What’s this ECT’s full name?")
  end

  def then_i_should_be_on_trn_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_should_be_on_the_date_of_birth_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth?")
  end

  def then_i_should_be_on_the_confirm_transfer_page
    expect(page).to have_selector("h1", text: "Confirm #{@participant_data[:full_name]} is moving from another school")
  end

  def then_i_should_be_on_the_who_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
  end

  def then_i_should_be_on_the_teacher_start_date_page
    expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} moving to your school?")
  end

  def then_i_should_be_on_the_add_email_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s email address?")
  end

  def then_i_should_be_on_the_select_mentor_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s mentor be?")
  end

  def then_i_should_be_taken_to_the_schools_current_programme_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}'s new lead provider / delivery partner be?")
    expect(page).to have_text(@lead_provider.name)
    expect(page).to have_text(@delivery_partner.name)
  end

  def then_i_should_be_taken_to_the_check_your_answers_page
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_selector("dd", text: @mentor.user.full_name)
  end

  def then_i_should_be_on_the_complete_page
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We’ll let this person know")
  end

  # and

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def and_there_is_a_withdrawn_ect_who_will_be_transferring
    @participant_profile_ect = create(:ect, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_two)
    induction_record = Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme_two, start_date: 3.months.ago)
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
    @participant_profile_ect.teacher_profile.update!(trn: "1001000")

    ParticipantProfileState.create!(participant_profile: @participant_profile_ect, state: ParticipantProfileState.states[:withdrawn], cpd_lead_provider: @induction_programme_two.lead_provider&.cpd_lead_provider)
    @participant_profile_ect.training_status_withdrawn!
    induction_record.training_status_withdrawn!
  end

  def and_it_should_list_the_schools_mentors
    expect(page).to have_text(@mentor.user.full_name)
  end

  def and_the_participant_should_be_notified
    expect(ParticipantTransferMailer).to have_received(:with)
      .with(induction_record: @participant_profile_ect.induction_records.latest)
  end

  def and_the_schools_current_provider_is_notified
    induction_record = @participant_profile_ect.induction_records.latest
    expect(ParticipantTransferMailer).to have_received(:with)
      .with(induction_record:, lead_provider_profile: @lead_provider_profile)
  end

  def and_i_have_selected_my_cohort_tab
    click_on @cohort.description
  end

  def allow_participant_transfer_mailers
    allow(ParticipantTransferMailer).to receive(:with).and_call_original
  end

  def set_dqt_validation_result
    allow(DQTRecordCheck).to receive(:call).and_return(
      DQTRecordCheck::CheckResult.new(
        valid_dqt_response(@participant_data),
        true,
        true,
        true,
        false,
        3,
      ),
    )
  end

  def valid_dqt_response(participant_data)
    DQTRecordPresenter.new({
      "name" => participant_data[:full_name],
      "trn" => participant_data[:trn],
      "state_name" => "Active",
      "dob" => participant_data[:date_of_birth],
      "qualified_teacher_status" => { "qts_date" => 1.year.ago },
      "induction" => {
        "start_date" => 1.month.ago,
        "status" => "Active",
      },
    })
  end

  def set_participant_data
    @participant_data = {
      trn: "1001000",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1990, 10, 24),
      email: "sally-teacher@example.com",
    }
  end
end
