# frozen_string_literal: true

module ParticipantValidationSteps
  include Capybara::DSL

  def given_there_is_a_school_that_has_chosen_fip_for_2021
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
  end

  def given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    given_there_is_a_school_that_has_chosen_fip_for_2021
    lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    create(:partnership, school: @school, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: @cohort, challenge_deadline: 2.weeks.ago)
  end

  def given_there_is_a_school_that_has_chosen_cip_for_2021
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "CIP School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "core_induction_programme")
  end

  def and_i_am_signed_in_as_an_ect_participant
    profile = create(:participant_profile, :ect, school_cohort: @school_cohort)
    @user = profile.user
    @user.teacher_profile.update!(trn: nil)
    set_participant_data
    sign_in_as @user
  end

  def and_i_am_signed_in_as_a_mentor_participant
    profile = create(:participant_profile, :mentor, school_cohort: @school_cohort)
    @user = profile.user
    @user.teacher_profile.update!(trn: nil)
    set_participant_data
    sign_in_as @user
  end

  def and_i_am_signed_in_as_an_ect_participant_with_a_trn_already_set
    and_i_am_signed_in_as_an_ect_participant
    @user.teacher_profile.update!(trn: "9876543")
  end

  def and_i_am_signed_in_as_a_sit_mentor_participant
    profile = create(:participant_profile, :mentor, school_cohort: @school_cohort)
    @user = profile.user
    @user.create_induction_coordinator_profile!
    @user.induction_coordinator_profile.schools << @school
    @user.teacher_profile.update!(trn: nil)
    set_participant_data
    sign_in_as @user
  end

  def and_i_sign_in_again_as_the_same_user
    sign_in_as @user
  end

  def then_i_should_see_the_do_you_want_to_add_your_mentor_information_page
    expect(page).to have_selector("h1", text: "Do you want to add information about yourself as a mentor?")
    expect(page).to have_field("Yes, I want to add information now", visible: :all)
    expect(page).to have_field("No, I’ll do it later", visible: :all)
  end

  def then_i_should_see_the_what_is_your_trn_page
    expect(page).to have_selector("h1", text: "What’s your teacher reference number (TRN)?")
    expect(page).to have_field("Teacher reference number (TRN)", visible: :all)
  end

  def when_i_click_continue_to_proceed_with_validation
    validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
    allow(validator).to receive(:validate)
      .with(@participant_data)
      .and_return({ trn: @participant_data[:trn], qts: true, active_alert: false })
    click_on "Continue"
  end
  alias_method :and_i_click_continue_to_proceed_with_validation, :when_i_click_continue_to_proceed_with_validation

  def when_i_click_continue_to_proceed_with_validation_for_updated_name
    validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
    allow(validator).to receive(:validate)
      .with(@participant_data)
      .with(trn: @participant_data[:trn],
            full_name: "Sally Participant",
            date_of_birth: @participant_data[:date_of_birth],
            nino: @participant_data[:nino],
            config: { check_first_name_only: true })
      .and_return({ trn: @participant_data[:trn], qts: true, active_alert: false })
    click_on "Continue"
  end

  def when_i_click_continue_but_my_details_are_invalid
    validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
    allow(validator).to receive(:validate)
      .with(@participant_data)
      .and_return(nil)
    click_on "Continue"
  end
  alias_method :and_i_click_continue_but_my_details_are_invalid, :when_i_click_continue_but_my_details_are_invalid

  def and_i_click_continue_but_my_trn_is_invalid
    validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
    allow(validator).to receive(:validate)
      .with(@participant_data.merge(trn: @incorrect_trn))
      .and_return(nil)
    click_on "Continue"
  end

  def then_i_should_see_the_trn_page
    expect(page).to have_selector("h1", text: "What’s your teacher reference number (TRN)?")
    expect(page).to have_field("Full name")
    expect(page).to have_field("Day")
    expect(page).to have_field("Month")
    expect(page).to have_field("Year")
    expect(page).to have_field("National Insurance number (optional)")
  end

  def when_i_enter_my_trn
    fill_in "Teacher reference number (TRN)", with: @participant_data[:trn]
  end

  def when_i_enter_my_trn_incorrectly
    fill_in "Teacher reference number (TRN)", with: @incorrect_trn
  end

  def when_i_enter_my_details
    fill_in "Full name", with: @participant_data[:full_name]
    fill_in "Day", with: @participant_data[:date_of_birth].day
    fill_in "Month", with: @participant_data[:date_of_birth].month
    fill_in "Year", with: @participant_data[:date_of_birth].year
  end

  def then_i_should_see_the_cannot_find_details_page
    expect(page).to have_selector("h1", text: "We cannot find your details")
    expect(page).to have_text(@participant_data[:full_name])
    expect(page).to have_text(@participant_data[:trn])
    expect(page).to have_text(@participant_data[:date_of_birth].to_s(:govuk))
    expect(page).to have_button("Confirm and send")
  end

  def then_i_should_see_the_cannot_find_details_page_with_the_incorrect_trn
    expect(page).to have_selector("h1", text: "We cannot find your details")
    expect(page).to have_text(@participant_data[:full_name])
    expect(page).to have_text(@incorrect_trn)
    expect(page).to have_text(@participant_data[:date_of_birth].to_s(:govuk))
    expect(page).to have_button("Confirm and send")
  end

  def when_i_click_a_change_link
    find("dd.govuk-summary-list__actions > a.govuk-link", match: :first).click
  end

  def when_i_click_the_change_trn_link
    click_link "Change teacher reference number"
  end

  def when_i_update_the_participant_name
    fill_in "Full name", with: "Sally Participant"
  end

  def then_i_should_see_the_confirm_details_page_with_updated_name
    expect(page).to have_selector("h1", text: "Confirm these details")
    expect(page).to have_text("Sally Participant")
    expect(page).to have_text(@participant_data[:trn])
    expect(page).to have_text(@participant_data[:date_of_birth].to_s(:govuk))
  end

  def then_i_should_see_the_what_is_your_trn_page_filled_in
    expect(page).to have_field("Teacher reference number (TRN)", with: @participant_data[:trn])
  end

  def then_i_should_see_the_what_is_your_trn_page_filled_in_incorrectly
    expect(page).to have_field("Teacher reference number (TRN)", with: @incorrect_trn)
  end

  def then_i_should_see_the_tell_us_your_details_page_filled_in
    expect(page).to have_field("Full name", with: @participant_data[:full_name])
    expect(page).to have_field("Day", with: @participant_data[:date_of_birth].day)
    expect(page).to have_field("Month", with: @participant_data[:date_of_birth].month)
    expect(page).to have_field("Year", with: @participant_data[:date_of_birth].year)
    expect(page).to have_field("National Insurance number (optional)")
  end

  def then_i_should_see_the_complete_page
    expect(page).to have_selector("h1", text: "You're eligible for this programme")
    expect(page).to have_text("You will not need to use this service again during your training.")
    expect(page).to have_text("Big Provider Ltd")
    expect(page).to have_text("Amazing Delivery Team")
    expect(page).not_to have_link("Manage induction for your school")
  end

  def then_i_should_see_the_complete_page_for_a_sit_mentor
    expect(page).to have_selector("h1", text: "Information submitted")
    expect(page).to have_text("We may need to contact you for more information to complete your registration.")
    expect(page).not_to have_text("You will not need to use this service again during your training.")
    expect(page).to have_text("Big Provider Ltd")
    expect(page).to have_text("Amazing Delivery Team")
    expect(page).to have_link("Manage induction for your school")
  end

  def then_i_should_see_the_complete_page_for_matched_user
    then_i_should_see_the_complete_page
    expect(@user.reload.teacher_profile.trn).to eq(@participant_data[:trn])
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_eligible_status
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_complete_page_for_matched_cip_ect_participant
    expect(page).to have_selector("h1", text: "You're eligible for this programme")
    expect(page).to have_text("We’ll email you a link to access your materials within the next 24 hours.")
    expect(@user.reload.teacher_profile.trn).to eq(@participant_data[:trn])
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_eligible_status
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_complete_page_for_matched_cip_mentor_participant
    expect(page).to have_selector("h1", text: "You're eligible for this programme")
    expect(page).to have_text("We’ll email you a link to access your materials within the next 24 hours.")
    expect(@user.reload.teacher_profile.trn).to eq(@participant_data[:trn])
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_eligible_status
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_fip_checking_details_page_for_invalid_user
    expect(page).to have_selector("h1", text: "Information submitted")
    expect(page).not_to have_link("Manage induction for your school")
    expect(@user.reload.teacher_profile.trn).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_fip_checking_details_page_for_existing_trn_user
    expect(page).to have_selector("h1", text: "Information submitted")
    expect(page).not_to have_link("Manage induction for your school")
    expect(@user.reload.teacher_profile.trn).to eq "9876543"
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_present
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).not_to be_api_failure
  end

  def then_i_should_see_the_cip_checking_details_page_for_invalid_cip_ect
    expect(page).to have_selector("h1", text: "You're eligible for this programme")
    expect(page).to have_text("We’ll email you a link to access your materials within the next 24 hours.")
    expect(page).not_to have_link("Manage induction for your school")
    expect(@user.reload.teacher_profile.trn).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_cip_checking_details_page_for_invalid_cip_mentor
    expect(page).to have_text("We’ll email you a link to access your materials within the next 24 hours.")
    expect(page).not_to have_text("Your training materials will be available by the end of August. We’ll email you with a link to access them.")
    expect(page).not_to have_link("Manage induction for your school")
    expect(@user.reload.teacher_profile.trn).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_eligibility).to be_nil
    expect(@user.teacher_profile.participant_profiles.ecf.first.ecf_participant_validation_data).to be_present
  end

  def then_i_should_see_the_get_a_trn_page
    expect(page).to have_selector("h1", text: "How to get your teacher reference number (TRN)")
    expect(page).to have_link("qts.enquiries@education.gov.uk")
    expect(page).to have_link("https://manager.galaxkey.com/services/registerme")
    expect(page).to have_link("teacher self-service site", href: "https://www.gov.uk/guidance/teacher-self-service-portal")
  end

  def then_i_should_see_the_manage_your_training_page
    expect(page).to have_selector("h1", text: "Manage your training")
  end

  def and_i_should_see_a_banner_telling_me_i_need_to_add_my_mentor_information
    banner = find("[data-test='add-mentor-information-banner']")
    expect(banner).to have_selector("h2", text: "Important")
    expect(banner).to have_selector("div.govuk-notification-banner__heading", text: "You need to add information about yourself as a mentor.")
    expect(banner).to have_link("Update now", href: participants_validation_what_is_your_trn_path)
  end

  def and_i_should_not_see_a_banner_telling_me_i_need_to_add_my_mentor_information
    expect(page).not_to have_selector("[data-test='add-mentor-information-banner']")
  end

  def set_participant_data
    @incorrect_trn = "1223456"
    @participant_data = {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      nino: nil,
      config: { check_first_name_only: true },
    }
  end
end
