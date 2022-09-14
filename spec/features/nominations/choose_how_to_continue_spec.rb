# frozen_string_literal: true

require "rails_helper"
require_relative "./nominate_induction_tutor_steps"

RSpec.feature "ECT nominate SIT journey", type: :feature, js: true do
  include NominateInductionTutorSteps

  before do
    given_a_valid_nomination_email_has_been_created
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page
    and_the_page_should_be_accessible
  end

  scenario "School expects ECTs to join in the current academic year" do
    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible
  end

  scenario "School does not expect any early career teachers to join in the current academic year" do
    when_i_select "no"
    click_on "Continue"
    then_i_should_be_redirected_to_the_choice_saved_page
    and_the_page_should_be_accessible
  end

  scenario "School does not know whether they will have an early career teachers join in the current academic year" do
    when_i_select "we_dont_know"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible
  end
end
