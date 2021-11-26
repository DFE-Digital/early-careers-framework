# frozen_string_literal: true

module NominateInductionTutorSteps
  include Capybara::DSL

  def given_a_valid_nomination_email_has_been_created
    @nomination_email = create(:nomination_email)
    @school_cohort = create(:school_cohort, :fip, school: @nomination_email.school)
  end

  def given_an_induction_tutor_has_already_been_nominated
    @nomination_email = create(:nomination_email, :already_nominated_induction_tutor)
  end

  def given_an_email_address_for_another_school_sit_already_exists
    @nomination_email = create(:nomination_email, :email_address_already_used_for_another_school)
    @school_cohort = create(:school_cohort, :fip, school: @nomination_email.school)
  end

  def given_an_email_is_being_used_by_an_existing_ect
    given_a_valid_nomination_email_has_been_created
    @ect = create(:ect_participant_profile, user: create(:user, full_name: "John Doe", email: "johndo2@example.com"))
  end

  def and_the_nomination_email_link_has_expired
    @nomination_email.update(sent_at: 22.days.ago)
  end

  def when_i_click_the_link_to_nominate_a_sit
    visit choose_how_to_continue_path(params: { token: @nomination_email.token })
  end

  def when_i_fill_in_the_sits_name
    set_participant_data
    fill_in "nominate_induction_tutor_form[full_name]", with: @sit_data[:full_name]
  end

  def when_i_fill_in_the_sits_email
    set_participant_data
    fill_in "nominate_induction_tutor_form[email]", with: @sit_data[:email]
  end

  def when_i_fill_in_the_correct_name
    fill_in "nominate_induction_tutor_form[full_name]", with: "John Smith"
  end

  def when_i_fill_in_using_an_email_that_is_already_being_used
    fill_in "nominate_induction_tutor_form[email]", with: "john-smith@example.com"
  end

  def when_i_fill_in_using_an_ects_email
    fill_in "nominate_induction_tutor_form[email]", with: @ect.user.email
  end

  def when_i_input_an_invalid_email_format
    fill_in "nominate_induction_tutor_form[email]", with: "invalid-email@example"
  end

  def when_i_select(option)
    choose option: option, allow_label_click: true
  end

  def then_i_should_be_on_the_choose_how_to_continue_page
    expect(page).to have_selector("h1", text: "Do you expect any early career teachers to join your school this academic year?")
    expect(page).to have_field("Yes", visible: :all)
    expect(page).to have_field("No", visible: :all)
    expect(page).to have_field("We do not know", visible: :all)
  end

  def then_i_should_be_on_the_start_nomination_page
    expect(page).to have_selector("h1", text: "Nominate an induction tutor for your school")
    expect(page).to have_text("Your induction tutor will use our online service to:")
    expect(page).to have_selector("h2", text: "Who you can nominate")
    expect(page).to have_text("choose how your school wants to run your early career teacher(ECT) training programme")
  end

  def then_i_should_be_on_the_nominations_full_name_page
    expect(page).to have_selector("label", text: "What’s the full name of your induction tutor?")
  end

  def then_i_should_be_on_the_nominations_email_page
    expect(page).to have_selector("label", text: "What’s #{@sit_data[:full_name]}’s email address?")
  end

  def then_i_should_be_back_on_the_nominations_email_page
    expect(page).to have_selector("label", text: "What’s John Smith’s email address?")
  end

  def then_i_should_be_on_the_check_details_page
    expect(page).to have_selector("h1", text: "Check your answers")
  end

  def then_i_should_be_on_the_nominate_sit_success_page
    expect(page).to have_selector("h1", text: "Induction tutor nominated")
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We'll email this person and let them know you nominated them.")
  end

  def then_i_should_be_redirected_to_name_different_page
    expect(page).to have_selector("h1", text: "The name you entered does not match our records")
  end

  def then_i_should_be_redirected_to_the_choice_saved_page
    expect(page).to have_text("We will contact #{@nomination_email.school.name} in the next academic year.")
  end

  def then_i_should_receive_a_full_name_error_message
    expect(page).to have_text("Enter a full name")
  end

  def then_i_should_receive_a_blank_email_error_message
    expect(page).to have_text("Enter an email")
  end

  def then_i_should_receive_an_invalid_email_error_message
    expect(page).to have_text("Enter an email address in the correct format, like name@example.com")
  end

  def then_i_should_be_redirected_to_the_link_expired_page
    expect(page).to have_selector("h1", text: "This link has expired")
    expect(page).to have_text("You need to request another email with a new link")
  end

  def then_i_should_be_redirected_to_the_induction_tutor_already_nominated_page
    expect(page).to have_selector("h1", text: "An induction tutor has already been nominated")
    expect(page).to have_text("Your school has already nominated an induction tutor to use our service.")
  end

  def then_i_should_be_on_the_email_already_used_page
    expect(page).to have_selector("h1", text: "The email address is being used by another school")
  end

  def set_participant_data
    @sit_data = {
      full_name: "John Doe",
      email: "johndoe@example.com",
    }
  end
end
